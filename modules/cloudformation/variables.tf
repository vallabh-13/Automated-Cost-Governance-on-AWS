variable "project_name" {
  description = "Short name used for tagging and resource prefixes."
  type        = string
}

variable "tags" {
  description = "Additional tags applied to CloudFormation resources."
  type        = map(string)
  default     = {}
}

variable "governance_tag_value" {
  description = "Tag value used to scope cleanup actions (e.g., CostGovernance=true)."
  type        = string
  default     = "true"
}

variable "availability_zone" {
  description = "Availability zone for EBS volumes in CloudFormation stack."
  type        = string
}
