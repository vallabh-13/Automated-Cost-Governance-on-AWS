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
  name_prefix = "${var.project_name}-sns"
  common_tags = merge(
    {
      "Project"   = var.project_name
      "ManagedBy" = "terraform"
    },
    var.tags
  )
}

# SNS Topic for cost governance notifications
resource "aws_sns_topic" "cost_governance" {
  name = "${local.name_prefix}-topic"
  tags = local.common_tags
}

# Email subscriptions for approvers
resource "aws_sns_topic_subscription" "approver_emails" {
  for_each = toset(var.approver_emails)

  topic_arn = aws_sns_topic.cost_governance.arn
  protocol  = "email"
  endpoint  = each.value
}
