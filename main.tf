terraform {
  required_version = ">= 1.6.0"

  # Backend for storing Terraform state (replace with your actual bucket)
  backend "s3" {
    bucket = "remote-bucket-cost-governance"
    key    = "cost-governance/terraform.tfstate"
    region = "us-east-2"
  }
}

provider "aws" {
  region = var.region
}

# SNS Notifications
module "sns" {
  source          = "./modules/sns"
  project_name    = var.project_name
  approver_emails = var.approver_emails
  tags            = var.tags
}

# EC2 Wasteful Instances
module "ec2" {
  source               = "./modules/ec2"
  project_name         = var.project_name
  ami_id               = var.ami_id
  instance_type        = var.instance_type
  instance_count       = var.instance_count
  volume_count         = var.volume_count
  availability_zone    = var.availability_zone
  governance_tag_value = "true"
  tags                 = var.tags
}

# CloudWatch Alarms
module "cloudwatch" {
  source         = "./modules/cloudwatch"
  project_name   = var.project_name
  instance_ids   = module.ec2.wasteful_instance_ids
  cpu_threshold  = 2
  sns_topic_arn  = module.sns.sns_topic_arn
  region         = var.region
  tags           = var.tags
}

# S3 Wasteful Bucket + Frontend Hosting
module "s3" {
  source               = "./modules/s3"
  project_name         = var.project_name
  governance_tag_value = "true"
  tags                 = var.tags
}

# Cost Explorer
module "cost_explorer" {
  source              = "./modules/cost-explorer"
  project_name        = var.project_name
  budget_limit        = var.budget_limit
  budget_threshold    = var.budget_threshold
  notification_emails = var.approver_emails
  effective_start     = "2025-01-01T00:00:00Z"
  sns_topic_arn       = module.sns.sns_topic_arn
  tags                = var.tags
}

# CloudFormation Wasteful Stack
module "cloudformation" {
  source               = "./modules/cloudformation"
  project_name         = var.project_name
  governance_tag_value = "true"
  availability_zone    = var.availability_zone
  tags                 = var.tags
}

# IAM Roles for SSM Automation and Approvers
module "iam" {
  source                  = "./modules/iam"
  project_name            = var.project_name
  governance_tag_value    = "true"
  s3_bucket_name          = module.s3.s3_bucket_name
  sns_topic_arn           = module.sns.sns_topic_arn
  approver_principal_arns = var.approver_principal_arns
  tags                    = var.tags
}

# SSM Automation for Cost Cleanup
module "ssm" {
  source                  = "./modules/ssm"
  project_name            = var.project_name
  ssm_automation_role_arn = module.iam.ssm_automation_role_arn
  sns_topic_arn           = module.sns.sns_topic_arn
  cleanup_tag             = "CostGovernance=true"
  frontend_bucket_name    = module.s3.s3_bucket_name
  s3_transition_days      = 30
  s3_glacier_days         = 90
  s3_expire_days          = 365
  tags                    = var.tags
}

# EventBridge to trigger SSM automation on CloudWatch alarms
module "eventbridge" {
  source                  = "./modules/eventbridge"
  project_name            = var.project_name
  region                  = var.region
  ssm_document_name       = module.ssm.ssm_document_name
  ssm_automation_role_arn = module.iam.ssm_automation_role_arn
  sns_topic_arn           = module.sns.sns_topic_arn
  s3_bucket_name          = module.s3.s3_bucket_name
  approver_arn            = var.approver_arn != "" ? var.approver_arn : data.aws_caller_identity.current.arn
  tags                    = var.tags
}

data "aws_caller_identity" "current" {}
