output "cloudwatch_alarm_names" {
  description = "Names of CloudWatch alarms created for idle EC2 detection."
  value       = [for a in aws_cloudwatch_metric_alarm.idle_ec2_cpu : a.alarm_name]
}

output "cloudwatch_dashboard_name" {
  description = "Name of the CloudWatch dashboard for cost governance."
  value       = aws_cloudwatch_dashboard.cost_governance.dashboard_name
}
