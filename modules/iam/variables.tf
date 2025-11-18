variable "project_name" {
  description = "Short name used for tagging and resource prefixes."
  type        = string
}

variable "tags" {
  description = "Additional tags applied to IAM resources."
  type        = map(string)
  default     = {}
}

variable "governance_tag_value" {
  description = "Tag value used to scope cleanup actions (e.g., CostGovernance=true)."
  type        = string
  default     = "true"
}

variable "s3_bucket_name" {
  description = "Target S3 bucket name for lifecycle governance actions."
  type        = string
}

variable "approver_principal_arns" {
  description = "List of AWS principal ARNs (users/roles) allowed to assume the approver role."
  type        = list(string)
  default     = []
}

variable "sns_topic_arn" {
  description = "SNS topic ARN for approval notifications."
  type        = string
}
