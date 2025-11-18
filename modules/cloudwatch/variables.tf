variable "project_name" {
  description = "Short name used for tagging and resource prefixes."
  type        = string
}

variable "tags" {
  description = "Additional tags applied to CloudWatch resources."
  type        = map(string)
  default     = {}
}

variable "instance_ids" {
  description = "List of EC2 instance IDs to monitor for idle detection."
  type        = list(string)
  default     = []
}

variable "cpu_threshold" {
  description = "CPU utilization threshold (%) below which an instance is considered idle."
  type        = number
  default     = 2
}

variable "sns_topic_arn" {
  description = "SNS topic ARN for sending alarm notifications."
  type        = string
}

variable "region" {
  description = "AWS region for CloudWatch dashboard."
  type        = string
  default     = "us-east-1"
}
