output "eventbridge_rule_arn" {
  description = "ARN of the EventBridge rule for CloudWatch alarms"
  value       = aws_cloudwatch_event_rule.alarm_trigger.arn
}

output "eventbridge_rule_name" {
  description = "Name of the EventBridge rule for CloudWatch alarms"
  value       = aws_cloudwatch_event_rule.alarm_trigger.name
}

output "budget_eventbridge_rule_arn" {
  description = "ARN of the EventBridge rule for Budget notifications (if enabled)"
  value       = var.budget_trigger_enabled ? aws_cloudwatch_event_rule.budget_trigger[0].arn : null
}

output "budget_eventbridge_rule_name" {
  description = "Name of the EventBridge rule for Budget notifications (if enabled)"
  value       = var.budget_trigger_enabled ? aws_cloudwatch_event_rule.budget_trigger[0].name : null
}
