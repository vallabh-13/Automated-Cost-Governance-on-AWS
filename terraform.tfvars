project_name       = "cost-governance-demo"
region             = "us-east-2"
availability_zone  = "us-east-2a"

# Replace with AMI from Step 2
ami_id             = "ami-xxxxxxxxxxxxx"
instance_type      = "t3.medium"
instance_count     = 1
volume_count       = 1

# Replace with your email
approver_emails = [
  "your-email@example.com"
]

# Replace with your IAM user ARN
approver_arn = "arn:aws:iam::123456789012:user/your-username"

budget_limit       = 2
budget_threshold   = 50

tags = {
  Environment = "demo"
  ManagedBy   = "terraform"
}