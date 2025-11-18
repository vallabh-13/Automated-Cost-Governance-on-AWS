output "sns_topic_arn" {
  description = "ARN of the SNS topic for notifications"
  value       = module.sns.sns_topic_arn
}

output "cloudwatch_dashboard" {
  description = "Name of the CloudWatch dashboard"
  value       = module.cloudwatch.cloudwatch_dashboard_name
}

output "wasteful_instance_ids" {
  description = "IDs of wasteful EC2 instances"
  value       = module.ec2.wasteful_instance_ids
}

output "unattached_volume_ids" {
  description = "IDs of unattached EBS volumes"
  value       = module.ec2.unattached_volume_ids
}

output "s3_bucket_name" {
  description = "Name of the S3 bucket hosting the static site"
  value       = module.s3.s3_bucket_name
}

output "s3_website_endpoint" {
  description = "Website endpoint of the static site"
  value       = module.s3.s3_website_endpoint
}

output "frontend_url" {
  description = "Public URL of the hosted frontend"
  value       = module.s3.s3_website_endpoint
}

output "budget_name" {
  description = "Name of the AWS budget created"
  value       = module.cost_explorer.budget_name
}

output "cost_category_name" {
  description = "Name of the Cost Explorer category"
  value       = module.cost_explorer.cost_category_name
}

output "cloudformation_stack_name" {
  description = "Name of the wasteful CloudFormation stack"
  value       = module.cloudformation.cloudformation_stack_name
}

output "ssm_automation_role_arn" {
  description = "ARN of IAM role used by SSM Automation"
  value       = module.iam.ssm_automation_role_arn
}

output "approver_role_arn" {
  description = "ARN of IAM role for approvers"
  value       = module.iam.approver_role_arn
}

output "ssm_document_name" {
  description = "Name of SSM automation document for cleanup"
  value       = module.ssm.ssm_document_name
}
