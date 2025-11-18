output "ssm_automation_role_arn" {
  description = "ARN of the SSM Automation execution role."
  value       = aws_iam_role.ssm_automation_role.arn
}

output "approver_role_arn" {
  description = "ARN of the IAM role used by human approvers."
  value       = aws_iam_role.approver_role.arn
}

output "ssm_cleanup_policy_arn" {
  description = "ARN of the policy attached to the SSM automation role for cleanup actions."
  value       = aws_iam_policy.ssm_cleanup.arn
}
