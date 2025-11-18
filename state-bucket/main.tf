terraform {
  required_version = ">= 1.6.0"
}

provider "aws" {
  region = "us-east-2" # match your root backend region
}

locals {
  bucket_name = "remote-bucket-cost-governance"
  common_tags = {
    Project   = "cost-governance"
    ManagedBy = "terraform"
  }
}

# Create S3 bucket for Terraform remote state
resource "aws_s3_bucket" "state_bucket" {
  bucket = local.bucket_name
  tags   = local.common_tags
}

# Enable versioning for state safety
resource "aws_s3_bucket_versioning" "state_versioning" {
  bucket = aws_s3_bucket.state_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Block public access (best practice for state buckets)
resource "aws_s3_bucket_public_access_block" "state_bucket_block" {
  bucket                  = aws_s3_bucket.state_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Optional: enable server-side encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "state_bucket_encryption" {
  bucket = aws_s3_bucket.state_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

output "state_bucket_name" {
  description = "Name of the S3 bucket used for Terraform state"
  value       = aws_s3_bucket.state_bucket.bucket
}
