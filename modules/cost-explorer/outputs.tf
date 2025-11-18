output "budget_name" {
  description = "Name of the AWS budget created for cost governance."
  value       = aws_budgets_budget.monthly_cost_budget.name
}

output "budget_arn" {
  description = "ARN of the AWS budget created for cost governance."
  value       = aws_budgets_budget.monthly_cost_budget.arn
}

output "cost_category_name" {
  description = "Name of the Cost Explorer category for governance."
  value       = aws_ce_cost_category.governance_category.name
}

output "eventbridge_notification_enabled" {
  description = "Whether EventBridge notifications are enabled for the budget."
  value       = var.enable_eventbridge_notification
}
