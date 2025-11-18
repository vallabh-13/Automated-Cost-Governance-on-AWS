terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0"
    }
  }
}

locals {
  name_prefix = "${var.project_name}-frontend"
  common_tags = merge(
    {
      "Project"        = var.project_name
      "ManagedBy"      = "terraform"
      "CostGovernance" = var.governance_tag_value
    },
    var.tags
  )
}

# Create S3 bucket for frontend hosting
resource "aws_s3_bucket" "frontend_bucket" {
  bucket = "${local.name_prefix}-bucket"
  tags   = local.common_tags
}

# Enable static website hosting
resource "aws_s3_bucket_website_configuration" "frontend_website" {
  bucket = aws_s3_bucket.frontend_bucket.bucket

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

# Public access block (disable to allow website hosting)
resource "aws_s3_bucket_public_access_block" "frontend_public_access" {
  bucket                  = aws_s3_bucket.frontend_bucket.bucket
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# Bucket policy for public read access (needed for static site hosting)
resource "aws_s3_bucket_policy" "frontend_policy" {
  bucket = aws_s3_bucket.frontend_bucket.bucket

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = ["s3:GetObject"]
        Resource  = "${aws_s3_bucket.frontend_bucket.arn}/*"
      }
    ]
  })

  depends_on = [aws_s3_bucket_public_access_block.frontend_public_access]
}

# Upload all files from frontend/ directory automatically
resource "aws_s3_object" "frontend_files" {
  for_each = fileset("${path.module}/../../frontend", "**")

  bucket = aws_s3_bucket.frontend_bucket.bucket
  key    = each.value
  source = "${path.module}/../../frontend/${each.value}"
  etag   = filemd5("${path.module}/../../frontend/${each.value}")

  content_type = lookup(
    var.mime_types,
    regex("\\.[^.]+$", each.value),
    "application/octet-stream"
  )

  tags = merge(local.common_tags, {
    "Name" = each.value
  })
}
