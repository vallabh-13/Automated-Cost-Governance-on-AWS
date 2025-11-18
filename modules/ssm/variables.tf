variable "project_name" {
  description = "Short name used for tagging and resource prefixes."
  type        = string
}

variable "tags" {
  description = "Additional tags applied to SSM resources."
  type        = map(string)
  default     = {}
}

variable "ssm_automation_role_arn" {
  description = "IAM role ARN used by SSM Automation to execute cleanup."
  type        = string
}

variable "sns_topic_arn" {
  description = "SNS topic ARN for sending approval notifications."
  type        = string
}

variable "cleanup_tag" {
  description = "Tag value used to identify resources for cleanup."
  type        = string
  default     = "CostGovernance=true"
}

variable "frontend_bucket_name" {
  description = "Frontend S3 bucket name to apply lifecycle policy after cleanup."
  type        = string
  default     = ""
}

variable "s3_transition_days" {
  description = "Days before S3 objects transition to infrequent access storage."
  type        = number
  default     = 30
}

variable "s3_glacier_days" {
  description = "Days before S3 objects transition to Glacier storage."
  type        = number
  default     = 90
}

variable "s3_expire_days" {
  description = "Days before S3 objects expire (set 0 to skip expiration)."
  type        = number
  default     = 365
}
