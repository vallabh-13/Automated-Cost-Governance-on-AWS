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
  name_prefix = "${var.project_name}-eventbridge"
  common_tags = merge(
    {
      "Project"   = var.project_name
      "ManagedBy" = "terraform"
    },
    var.tags
  )
}

# EventBridge rule to trigger SSM automation on CloudWatch alarm state change
resource "aws_cloudwatch_event_rule" "alarm_trigger" {
  name        = "${local.name_prefix}-alarm-trigger"
  description = "Trigger SSM automation when CloudWatch alarms enter ALARM state"

  event_pattern = jsonencode({
    source      = ["aws.cloudwatch"]
    detail-type = ["CloudWatch Alarm State Change"]
    detail = {
      state = {
        value = ["ALARM"]
      }
      alarmName = [{
        prefix = var.project_name
      }]
    }
  })

  tags = local.common_tags
}

# EventBridge target - SSM Automation
resource "aws_cloudwatch_event_target" "ssm_automation" {
  rule      = aws_cloudwatch_event_rule.alarm_trigger.name
  target_id = "TriggerSSMAutomation"
  arn       = "arn:aws:ssm:${var.region}::automation-definition/${var.ssm_document_name}:$DEFAULT"
  role_arn  = aws_iam_role.eventbridge_ssm_role.arn

  input_transformer {
    input_paths = {
      alarmName = "$.detail.alarmName"
      region    = "$.region"
    }
    input_template = jsonencode({
      AutomationAssumeRole = [var.ssm_automation_role_arn]
      NotificationArn      = [var.sns_topic_arn]
      S3BucketName         = [var.s3_bucket_name]
      Approver             = [var.approver_arn]
    })
  }
}

# IAM role for EventBridge to start SSM automation
resource "aws_iam_role" "eventbridge_ssm_role" {
  name = "${local.name_prefix}-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "events.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = local.common_tags
}

# IAM policy for EventBridge to start SSM automation
resource "aws_iam_role_policy" "eventbridge_ssm_policy" {
  name = "${local.name_prefix}-ssm-policy"
  role = aws_iam_role.eventbridge_ssm_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ssm:StartAutomationExecution"
        ]
        Resource = [
          "arn:aws:ssm:${var.region}:${data.aws_caller_identity.current.account_id}:automation-definition/${var.ssm_document_name}:*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "iam:PassRole"
        ]
        Resource = [
          var.ssm_automation_role_arn
        ]
        Condition = {
          StringEquals = {
            "iam:PassedToService" = "ssm.amazonaws.com"
          }
        }
      }
    ]
  })
}

data "aws_caller_identity" "current" {}

# EventBridge rule to trigger SSM automation on Budget threshold exceeded
# This is configured but not active by default (enable via budget_trigger_enabled variable)
resource "aws_cloudwatch_event_rule" "budget_trigger" {
  count       = var.budget_trigger_enabled ? 1 : 0
  name        = "${local.name_prefix}-budget-trigger"
  description = "Trigger SSM automation when AWS Budget threshold is exceeded"

  event_pattern = jsonencode({
    source      = ["aws.budgets"]
    detail-type = ["Budget Notification"]
    detail = {
      notificationType = ["ACTUAL"]
      comparison       = ["GREATER_THAN"]
    }
  })

  tags = local.common_tags
}

# EventBridge target for budget - SSM Automation
resource "aws_cloudwatch_event_target" "budget_ssm_automation" {
  count     = var.budget_trigger_enabled ? 1 : 0
  rule      = aws_cloudwatch_event_rule.budget_trigger[0].name
  target_id = "TriggerSSMAutomationFromBudget"
  arn       = "arn:aws:ssm:${var.region}::automation-definition/${var.ssm_document_name}:$DEFAULT"
  role_arn  = aws_iam_role.eventbridge_ssm_role.arn

  input_transformer {
    input_paths = {
      budgetName = "$.detail.budgetName"
      threshold  = "$.detail.thresholdPercentage"
    }
    input_template = jsonencode({
      AutomationAssumeRole = [var.ssm_automation_role_arn]
      NotificationArn      = [var.sns_topic_arn]
      S3BucketName         = [var.s3_bucket_name]
      Approver             = [var.approver_arn]
    })
  }
}
