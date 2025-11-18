variable "project_name" {
  description = "Project name prefix for all resources"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "availability_zone" {
  description = "Availability zone for EBS volumes"
  type        = string
}

variable "ami_id" {
  description = "AMI ID for EC2 instances"
  type        = string
}

variable "instance_type" {
  description = "Instance type for wasteful EC2 instances"
  type        = string
}

variable "instance_count" {
  description = "Number of wasteful EC2 instances to deploy"
  type        = number
}

variable "volume_count" {
  description = "Number of unattached EBS volumes to create"
  type        = number
}

variable "approver_emails" {
  description = "List of approver emails for SNS notifications"
  type        = list(string)
}

variable "approver_principal_arns" {
  description = "List of AWS principal ARNs allowed to approve SSM automations"
  type        = list(string)
  default     = []
}

variable "approver_arn" {
  description = "ARN of the primary approver for SSM automation (IAM user or role)"
  type        = string
  default     = ""
}

variable "budget_limit" {
  description = "Monthly budget limit in USD"
  type        = number
}

variable "budget_threshold" {
  description = "Percentage threshold for budget notifications"
  type        = number
}

variable "tags" {
  description = "Global tags applied to all resources"
  type        = map(string)
}
variable "mime_types" {
  description = "Mapping of file extensions to MIME types for S3 hosting"
  type        = map(string)
  default = {
    ".html" = "text/html"
    ".css"  = "text/css"
    ".js"   = "application/javascript"
    ".png"  = "image/png"
    ".jpg"  = "image/jpeg"
    ".jpeg" = "image/jpeg"
    ".gif"  = "image/gif"
    ".svg"  = "image/svg+xml"
    ".json" = "application/json"
  }
}
