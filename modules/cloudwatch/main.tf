terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

locals {
  name_prefix = "${var.project_name}-cloudwatch"
  common_tags = merge(
    {
      "Project"   = var.project_name
      "ManagedBy" = "terraform"
    },
    var.tags
  )
  # Convert list to map with indices as keys to make for_each work with unknown values
  instance_map = { for idx, id in var.instance_ids : tostring(idx) => id }
}

# Example: CloudWatch alarm for idle EC2 instance CPU utilization
# DEMO OPTIMIZED: 1 minute period, 1 evaluation for fast alarm trigger
resource "aws_cloudwatch_metric_alarm" "idle_ec2_cpu" {
  for_each            = local.instance_map
  alarm_name          = "${local.name_prefix}-idle-${each.value}"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = var.cpu_threshold
  alarm_description   = "Alarm when EC2 instance CPU utilization is below threshold (idle detection)."
  dimensions = {
    InstanceId = each.value
  }
  actions_enabled     = true
  alarm_actions       = [var.sns_topic_arn]
  ok_actions          = [var.sns_topic_arn]
  tags                = local.common_tags
}

# Optional: CloudWatch dashboard for cost governance visibility
resource "aws_cloudwatch_dashboard" "cost_governance" {
  dashboard_name = "${local.name_prefix}-dashboard"
  dashboard_body = <<EOF
{
  "widgets": [
    {
      "type": "metric",
      "x": 0,
      "y": 0,
      "width": 12,
      "height": 6,
      "properties": {
        "metrics": [
          [ "AWS/EC2", "CPUUtilization", "InstanceId", "${var.instance_ids[0]}" ]
        ],
        "period": 60,
        "stat": "Average",
        "region": "${var.region}",
        "title": "EC2 CPU Utilization (Idle Detection)"
      }
    }
  ]
}
EOF
}
