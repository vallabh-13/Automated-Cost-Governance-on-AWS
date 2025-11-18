output "ssm_document_name" {
  description = "Name of the SSM Automation Document."
  value       = aws_ssm_document.cost_cleanup.name
}

output "cleanup_tag_parameter" {
  description = "SSM Parameter Store name for cleanup tag."
  value       = aws_ssm_parameter.cleanup_tag.name
}
