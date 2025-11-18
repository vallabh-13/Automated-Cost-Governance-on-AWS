variable "project_name" {
  description = "Short name used for tagging and resource prefixes."
  type        = string
}

variable "tags" {
  description = "Additional tags applied to SNS resources."
  type        = map(string)
  default     = {}
}

variable "approver_emails" {
  description = "List of email addresses subscribed to SNS topic for approvals."
  type        = list(string)
  default     = []
}
