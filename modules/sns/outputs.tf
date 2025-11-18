output "sns_topic_arn" {
  description = "ARN of the SNS topic used for cost governance notifications."
  value       = aws_sns_topic.cost_governance.arn
}

output "sns_subscription_endpoints" {
  description = "List of email endpoints subscribed to the SNS topic."
  value       = [for s in aws_sns_topic_subscription.approver_emails : s.endpoint]
}
