output "wasteful_instance_ids" {
  description = "IDs of wasteful EC2 instances."
  value       = aws_instance.wasteful[*].id
}

output "unattached_volume_ids" {
  description = "IDs of unattached EBS volumes."
  value       = aws_ebs_volume.unattached[*].id
}
