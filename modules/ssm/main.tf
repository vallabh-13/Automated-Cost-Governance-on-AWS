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
  name_prefix = "${var.project_name}-ssm"
  common_tags = merge(
    {
      "Project" = var.project_name
      "ManagedBy" = "terraform"
    },
    var.tags
  )
}

# SSM Automation Document for cleanup
resource "aws_ssm_document" "cost_cleanup" {
  name          = "${local.name_prefix}-automation"
  document_type = "Automation"
  content       = data.template_file.cleanup_doc.rendered
  tags          = local.common_tags
}

# Template for Automation Document (JSON format)
data "template_file" "cleanup_doc" {
  template = file("${path.module}/templates/cleanup_automation.json")

  vars = {
    automation_role_arn = var.ssm_automation_role_arn
    sns_topic_arn       = var.sns_topic_arn
  }
}

# Optional: Parameter Store for dynamic inputs
resource "aws_ssm_parameter" "cleanup_tag" {
  name        = "/${var.project_name}/cleanup/tag"
  type        = "String"
  value       = var.cleanup_tag
  description = "Tag used to identify resources for cleanup"
  tags        = local.common_tags
}

# SSM Parameter for frontend bucket name (used for lifecycle policy application)
resource "aws_ssm_parameter" "frontend_bucket" {
  name        = "/${var.project_name}/s3/frontend-bucket-name"
  type        = "String"
  value       = var.frontend_bucket_name
  description = "Frontend S3 bucket name for lifecycle policy application after cleanup"
  tags        = local.common_tags
}

# SSM Parameter for S3 transition days
resource "aws_ssm_parameter" "s3_transition_days" {
  name        = "/${var.project_name}/s3/transition-days"
  type        = "String"
  value       = tostring(var.s3_transition_days)
  description = "Days before S3 objects transition to infrequent access"
  tags        = local.common_tags
}

# SSM Parameter for S3 Glacier transition days
resource "aws_ssm_parameter" "s3_glacier_days" {
  name        = "/${var.project_name}/s3/glacier-days"
  type        = "String"
  value       = tostring(var.s3_glacier_days)
  description = "Days before S3 objects transition to Glacier"
  tags        = local.common_tags
}

# SSM Parameter for S3 expiration days
resource "aws_ssm_parameter" "s3_expire_days" {
  name        = "/${var.project_name}/s3/expire-days"
  type        = "String"
  value       = tostring(var.s3_expire_days)
  description = "Days before S3 objects expire"
  tags        = local.common_tags
}
