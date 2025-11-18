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
  name_prefix = "${var.project_name}-cloudformation"
  common_tags = merge(
    {
      "Project"        = var.project_name
      "ManagedBy"      = "terraform"
      "CostGovernance" = var.governance_tag_value
    },
    var.tags
  )
}

# CloudFormation stack deploying intentionally wasteful resources
resource "aws_cloudformation_stack" "wasteful_stack" {
  name          = "${local.name_prefix}-stack"
  template_body = file("${path.module}/templates/wasteful_infra.json")

  parameters = {
    ProjectName        = var.project_name
    GovernanceTagKey   = "CostGovernance"
    GovernanceTagValue = var.governance_tag_value
    AvailabilityZone   = var.availability_zone
  }

  tags = local.common_tags
}
