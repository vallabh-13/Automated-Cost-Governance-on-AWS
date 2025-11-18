variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "ssm_document_name" {
  description = "Name of the SSM automation document"
  type        = string
}

variable "ssm_automation_role_arn" {
  description = "ARN of the SSM automation role"
  type        = string
}

variable "sns_topic_arn" {
  description = "SNS topic ARN for notifications"
  type        = string
}

variable "s3_bucket_name" {
  description = "S3 bucket name for lifecycle policy"
  type        = string
}

variable "approver_arn" {
  description = "ARN of the approver (IAM user or role)"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "budget_trigger_enabled" {
  description = "Enable EventBridge rule to trigger SSM automation on budget threshold violations. Set to false to use CloudWatch alarms only."
  type        = bool
  default     = true
}
