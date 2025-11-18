output "s3_bucket_name" {
  description = "Name of the S3 bucket hosting the frontend."
  value       = aws_s3_bucket.frontend_bucket.bucket
}

output "s3_website_endpoint" {
  description = "Website endpoint of the hosted frontend."
  value       = aws_s3_bucket_website_configuration.frontend_website.website_endpoint
}
