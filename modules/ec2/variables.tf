variable "project_name" {
  description = "Short name used for tagging and resource prefixes."
  type        = string
}

variable "tags" {
  description = "Additional tags applied to EC2 resources."
  type        = map(string)
  default     = {}
}

variable "governance_tag_value" {
  description = "Tag value used to scope cleanup actions (e.g., CostGovernance=true)."
  type        = string
  default     = "true"
}

variable "instance_count" {
  description = "Number of wasteful EC2 instances to deploy."
  type        = number
  default     = 2
}

variable "ami_id" {
  description = "AMI ID for EC2 instances."
  type        = string
}

variable "instance_type" {
  description = "Instance type for wasteful EC2 instances."
  type        = string
  default     = "t3.large"
}

variable "volume_count" {
  description = "Number of unattached EBS volumes to create."
  type        = number
  default     = 2
}

variable "availability_zone" {
  description = "Availability zone for EBS volumes."
  type        = string
}

variable "volume_size" {
  description = "Size of each unattached EBS volume (GB)."
  type        = number
  default     = 20
}
