output "cloudformation_stack_name" {
  description = "Name of the wasteful CloudFormation stack created by this module"
  value       = aws_cloudformation_stack.wasteful_stack.name
}
