variable "project_name" {
  description = "Short name used for tagging and resource prefixes."
  type        = string
}

variable "tags" {
  description = "Additional tags applied to Cost Explorer resources."
  type        = map(string)
  default     = {}
}

variable "budget_limit" {
  description = "Monthly budget limit in USD."
  type        = number
  default     = 10
}

variable "budget_threshold" {
  description = "Percentage threshold for budget notifications."
  type        = number
  default     = 80
}

variable "notification_emails" {
  description = "List of email addresses to notify when budget threshold is exceeded."
  type        = list(string)
  default     = []
}

variable "effective_start" {
  description = "Start date for Cost Category in ISO 8601 format (e.g., 2025-01-01T00:00:00Z)."
  type        = string
  default     = "2025-01-01T00:00:00Z"
}

variable "enable_eventbridge_notification" {
  description = "Enable EventBridge notifications for budget threshold violations (for automated remediation)."
  type        = bool
  default     = true
}

variable "sns_topic_arn" {
  description = "SNS topic ARN for budget EventBridge notifications. Only used if enable_eventbridge_notification is true."
  type        = string
  default     = ""
}
