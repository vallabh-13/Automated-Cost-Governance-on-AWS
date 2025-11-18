terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

locals {
  name_prefix = "${var.project_name}-ec2"
  common_tags = merge(
    {
      "Project"       = var.project_name
      "ManagedBy"     = "terraform"
      "CostGovernance" = var.governance_tag_value
    },
    var.tags
  )
}

# Over-provisioned EC2 instances (simulate waste)
resource "aws_instance" "wasteful" {
  count         = var.instance_count
  ami           = var.ami_id
  instance_type = var.instance_type

  tags = merge(local.common_tags, {
    "Name" = "${local.name_prefix}-wasteful-${count.index}"
  })
}

# Unattached EBS volumes (simulate waste)
resource "aws_ebs_volume" "unattached" {
  count             = var.volume_count
  availability_zone = var.availability_zone
  size              = var.volume_size

  tags = merge(local.common_tags, {
    "Name" = "${local.name_prefix}-unattached-${count.index}"
  })
}
