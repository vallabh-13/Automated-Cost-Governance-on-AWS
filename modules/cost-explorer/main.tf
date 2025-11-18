terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0"
    }
  }
}

locals {
  name_prefix = "${var.project_name}-costexplorer"
  common_tags = merge(
    {
      "Project"   = var.project_name
      "ManagedBy" = "terraform"
    },
    var.tags
  )
}

# AWS Budget for cost governance simulation
resource "aws_budgets_budget" "monthly_cost_budget" {
  name         = "${local.name_prefix}-budget"
  budget_type  = "COST"
  limit_amount = var.budget_limit
  limit_unit   = "USD"
  time_unit    = "MONTHLY"

  cost_filter {
    name   = "Service"
    values = ["Amazon Elastic Compute Cloud - Compute"]
  }

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = var.budget_threshold
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = var.notification_emails
  }

  # EventBridge notification for automated remediation
  dynamic "notification" {
    for_each = var.enable_eventbridge_notification && var.sns_topic_arn != "" ? [1] : []
    content {
      comparison_operator = "GREATER_THAN"
      threshold           = var.budget_threshold + 10  # Different threshold to avoid duplicate
      threshold_type      = "PERCENTAGE"
      notification_type   = "ACTUAL"
      subscriber_sns_topic_arns = [var.sns_topic_arn]
    }
  }

  tags = local.common_tags
}

# Cost Explorer category (correct syntax with nested rule blocks)
resource "aws_ce_cost_category" "governance_category" {
  name         = "${local.name_prefix}-category"
  rule_version = "CostCategoryExpression.v1"

  rule {
    value = "WastefulEC2"

    rule {
      dimension {
        key    = "SERVICE_CODE"
        values = ["AmazonEC2"]
      }
    }
  }

  rule {
    value = "WastefulS3"

    rule {
      dimension {
        key    = "SERVICE_CODE"
        values = ["AmazonS3"]
      }
    }
  }

  effective_start = var.effective_start

  tags = local.common_tags
}

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}
