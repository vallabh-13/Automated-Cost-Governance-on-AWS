terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

locals {
  name_prefix = "${var.project_name}-iam"
  common_tags = merge(
    {
      "Project" = var.project_name
      "ManagedBy" = "terraform"
    },
    var.tags
  )
}

# Role assumed by SSM Automation (execution role)
resource "aws_iam_role" "ssm_automation_role" {
  name               = "${local.name_prefix}-ssm-automation-role"
  assume_role_policy = data.aws_iam_policy_document.ssm_assume_role.json
  tags               = local.common_tags
}

data "aws_iam_policy_document" "ssm_assume_role" {
  statement {
    sid     = "AllowSSMAutomationToAssumeRole"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ssm.amazonaws.com"]
    }
  }
}

# Least-privilege policy allowing cleanup actions on selected resources
data "aws_iam_policy_document" "ssm_cleanup" {
  # EC2 read-only operations (no tag conditions - needed to discover resources)
  statement {
    sid    = "EC2ReadOnly"
    effect = "Allow"
    actions = [
      "ec2:DescribeInstances",
      "ec2:DescribeVolumes",
      "ec2:DescribeSnapshots",
      "ec2:DescribeAddresses",
      "ec2:DescribeTags"
    ]
    resources = ["*"]
  }

  # EC2 destructive operations (restricted by tag condition)
  statement {
    sid    = "EC2Cleanup"
    effect = "Allow"
    actions = [
      "ec2:StopInstances",
      "ec2:TerminateInstances",
      "ec2:DeleteVolume",
      "ec2:DeleteSnapshot",
      "ec2:ReleaseAddress",
      "ec2:CreateTags",
      "ec2:DeleteTags"
    ]
    resources = ["*"]
    # Restrict destructive operations to tagged resources only
    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/CostGovernance"
      values   = [var.governance_tag_value]
    }
  }

  # CloudWatch metrics for CPU utilization checking
  statement {
    sid    = "CloudWatchMetrics"
    effect = "Allow"
    actions = [
      "cloudwatch:GetMetricStatistics",
      "cloudwatch:GetMetricData",
      "cloudwatch:ListMetrics"
    ]
    resources = ["*"]
  }

  # S3 lifecycle and object-level tagging for cost governance
  statement {
    sid    = "S3Governance"
    effect = "Allow"
    actions = [
      "s3:GetBucketLocation",
      "s3:GetLifecycleConfiguration",
      "s3:PutLifecycleConfiguration",
      "s3:GetBucketTagging",
      "s3:PutBucketTagging",
      "s3:GetObjectTagging",
      "s3:PutObjectTagging",
      "s3:ListBucket"
    ]
    resources = [
      "arn:aws:s3:::${var.s3_bucket_name}",
      "arn:aws:s3:::${var.s3_bucket_name}/*"
    ]
  }

  # SSM document execution, parameter reads, and logging
  statement {
    sid    = "SSMAutomationCore"
    effect = "Allow"
    actions = [
      "ssm:StartAutomationExecution",
      "ssm:GetAutomationExecution",
      "ssm:DescribeAutomationExecutions",
      "ssm:DescribeAutomationStepExecutions",
      "ssm:GetDocument",
      "ssm:ListDocuments",
      "ssm:SendCommand",
      "ssm:GetCommandInvocation",
      "ssm:ListCommands",
      "ssm:GetParameter",
      "ssm:GetParameters",
      "ssm:GetParametersByPath",
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["*"]
  }

  # SNS publish for approval notifications
  statement {
    sid    = "SNSPublish"
    effect = "Allow"
    actions = [
      "sns:Publish"
    ]
    resources = [var.sns_topic_arn]
  }
}

resource "aws_iam_policy" "ssm_cleanup" {
  name        = "${local.name_prefix}-ssm-cleanup"
  description = "Least-privilege permissions for SSM automation cleanup across EC2/EBS/EIP and S3 governance."
  policy      = data.aws_iam_policy_document.ssm_cleanup.json
  tags        = local.common_tags
}

resource "aws_iam_role_policy_attachment" "attach_ssm_cleanup" {
  role       = aws_iam_role.ssm_automation_role.name
  policy_arn = aws_iam_policy.ssm_cleanup.arn
}

# Inline policy allowing SSM automation to pass roles it needs (self-pass role + instance role if used)
data "aws_iam_policy_document" "ssm_passrole" {
  statement {
    sid     = "AllowPassRoleToSSM"
    actions = ["iam:PassRole"]
    resources = [
      aws_iam_role.ssm_automation_role.arn
    ]
  }
}

resource "aws_iam_policy" "ssm_passrole" {
  name   = "${local.name_prefix}-ssm-passrole"
  policy = data.aws_iam_policy_document.ssm_passrole.json
  tags   = local.common_tags
}

resource "aws_iam_role_policy_attachment" "attach_ssm_passrole" {
  role       = aws_iam_role.ssm_automation_role.name
  policy_arn = aws_iam_policy.ssm_passrole.arn
}

# Approver role: humans can approve/reject automation via Change Manager or custom workflow
resource "aws_iam_role" "approver_role" {
  name               = "${local.name_prefix}-approver-role"
  assume_role_policy = data.aws_iam_policy_document.approver_assume.json
  tags               = local.common_tags
}

data "aws_iam_policy_document" "approver_assume" {
  statement {
    sid     = "AllowHumanUsersToAssume"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = length(var.approver_principal_arns) > 0 ? var.approver_principal_arns : [data.aws_caller_identity.current.arn]
    }
  }
}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "approver_permissions" {
  statement {
    sid    = "SSMApprovalActions"
    effect = "Allow"
    actions = [
      "ssm:DescribeAutomationExecutions",
      "ssm:DescribeAutomationStepExecutions",
      "ssm:GetAutomationExecution",
      "ssm:ListDocuments"
    ]
    resources = ["*"]
  }

  statement {
    sid     = "CloudWatchRead"
    effect  = "Allow"
    actions = ["cloudwatch:GetMetricData", "cloudwatch:ListMetrics", "cloudwatch:GetMetricStatistics"]
    resources = ["*"]
  }

  statement {
    sid     = "CostExplorerRead"
    effect  = "Allow"
    actions = [
      "ce:GetCostAndUsage",
      "ce:GetCostForecast",
      "ce:GetDimensionValues",
      "ce:GetSavingsPlansUtilization",
      "ce:GetRightsizingRecommendation"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "approver_permissions" {
  name   = "${local.name_prefix}-approver"
  policy = data.aws_iam_policy_document.approver_permissions.json
  tags   = local.common_tags
}

resource "aws_iam_role_policy_attachment" "attach_approver_permissions" {
  role       = aws_iam_role.approver_role.name
  policy_arn = aws_iam_policy.approver_permissions.arn
}
