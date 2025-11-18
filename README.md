# 💰 Automated Cost Governance on AWS (Cost Optimization Pillar)

## 📌 Project Overview
This Terraform-based project demonstrates **automated cost governance and optimization** using AWS native services. It deploys intentionally wasteful infrastructure, monitors costs in real-time, and automatically cleans up resources through automated script with approval workflow. The system showcases cost optimization patterns with event-driven automation, least-privilege security access and Terraform (Infrastructure as Code).

⚠️ **Note:** This project requires manual approval via **AWS Console** or **AWS CLI**. Email-only approval can be implemented using AWS Lambda with SNS triggers which is not implemented in this project.

## 🖼️ Architecture Diagram
![Architecture Diagram](./Diagram/Automated-Cost-Governance-on-AWS.png)

## ✅ Prerequisites
- AWS CLI authenticated to your account
- Terraform >= 1.6.0
- Valid AMI ID for your region (Amazon Linux 2)
- Email address for SNS notifications

- Basic knowledge of AWS cost management and automation

## 🎯 Key Objectives
- 💸 Deploy intentionally wasteful AWS infrastructure for demonstration
- 📊 Monitor costs with AWS Budgets and CloudWatch alarms
- 🤖 Automate resource cleanup using SSM Automation documents
- 📧 Implement email-based approval workflows via SNS
- 📈 Achieve cost reduction through automation

## 🏗️ Folder Structure
```
Automated-Cost-Governance-on-AWS/
├── .gitignore
├── Diagram/
│   └── Automated-Cost-Governance-on-AWS.png
├── frontend/
│   ├── index.html
│   └── styles.css
├── modules/
│   ├── cloudformation/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── cloudwatch/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── cost-explorer/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── ec2/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── eventbridge/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── iam/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── s3/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── sns/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── ssm/
│       ├── main.tf
│       ├── variables.tf
│       ├── outputs.tf
│       └── templates/
│           └── cleanup_automation.json
├── state-bucket/
│   └── main.tf
├── main.tf
├── variables.tf
├── terraform.tfvars.example
├── outputs.tf
└── README.md
```

## 🔁 Application Flow

### Cost Governance Workflow
1. **Wasteful Resources Deployed** → EC2 instances (idle), unattached EBS volumes, S3 Standard storage
2. **Monitoring Activated** → CloudWatch monitors CPU < 2%, AWS Budgets tracks spending
3. **Cost Threshold Exceeded** → AWS Budgets detects $1 spent (50% of $2 limit)
4. **Event Triggered** → Budget alert sent to SNS → EventBridge captures event
5. **Automation Initiated** → EventBridge triggers SSM Automation document
6. **Approval Request Sent** → SNS emails approver with resource cleanup list
7. **Manual Approval** → Approver reviews and approves via SSM Console
8. **Cleanup Executed** → SSM runs Python scripts to stop/terminate EC2, delete volumes, apply S3 lifecycle

## 🚀 Deployment Sequence

### ⚙️ Step 1: Clone Repository
```bash
git clone https://github.com/your-username/Automated-Cost-Governance-on-AWS.git
cd Automated-Cost-Governance-on-AWS
```

### ⚙️ Step 2: Get Valid AMI ID
```bash
# Get latest Amazon Linux 2 AMI for us-east-2
aws ec2 describe-images \
  --owners amazon \
  --filters "Name=name,Values=amzn2-ami-hvm-*-x86_64-gp2" \
  --region us-east-2 \
  --query 'sort_by(Images, &CreationDate)[-1].ImageId' \
  --output text
```

### ⚙️ Step 3: Configure Variables
Update `terraform.tfvars` with your values:
```hcl
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
```

### ⚙️ Step 4: Configure Remote State Backend
```bash
# Create S3 bucket for Terraform state
terraform -chdir=state-bucket init
terraform -chdir=state-bucket plan
terraform -chdir=state-bucket apply -auto-approve
```

### ⚙️ Step 5: Deploy Infrastructure
```bash
# Initialize Terraform
terraform init

# Preview changes
terraform plan -var-file="terraform.tfvars"

# Deploy all resources
terraform apply -var-file="terraform.tfvars"

```

### ⚙️ Step 6: Confirm SNS Subscription
1. Check your email inbox
2. Look for email from AWS SNS with subject **"AWS Notification - Subscription Confirmation"**
3. Click **"Confirm subscription"** link
4. You should see: **"Subscription confirmed!"**

### ⚙️ Step 7: Wait for Budget Alert (Optional)
Within 8-24 hours, AWS Budgets will detect costs exceeding threshold:
```
Subject: AWS Budget Alert
Body: Your budget "cost-governance-demo-costexplorer-budget"
      has exceeded 50% of $2.00 USD

```

### ⚙️ Step 8: Approve Cleanup in AWS Console

1. **Check email** for approval request:
   ```
   Subject: Approval request for SSM Automation
   Body: AWS Systems Manager requires approval for automation execution
         Resources to be cleaned:
         - EC2 Instances: [i-xxxxxxxxxxxxx]
         - EBS Volumes: [vol-xxxxxxxxxxxxx]
   ```

2. **Approve in AWS Console**:
   - Go to: **AWS Console → Systems Manager → Automation → Executions**
   - Find your execution ID
   - Click **"Approve"** button
   - Automation will proceed with cleanup

   **OR approve via AWS CLI**:
   ```bash
   aws ssm send-automation-signal \
     --automation-execution-id <YOUR-EXECUTION-ID> \
     --signal-type Approve \
     --region us-east-2
   ```

### ⚙️ Step 9: Teardown
```bash
# Destroy all infrastructure
terraform destroy -var-file="terraform.tfvars"

# Destroy remote state bucket
terraform -chdir=state-bucket destroy -auto-approve
```

## 🧩 Common Errors & Fixes

### ❌ Error: SSM automation fails with "Access Denied"
**Cause:** IAM role missing permissions
**Fix:**
- Verify SSM automation role has `ec2:TerminateInstances`, `ec2:StopInstances`, `ec2:DeleteVolume` permissions
- Check EventBridge role has `ssm:StartAutomationExecution` permission
- Review CloudWatch logs for detailed error messages

### ❌ Error: EventBridge rule not triggering
**Cause:** Event pattern mismatch or disabled rule
**Fix:**
```bash
# Check if EventBridge rule is enabled
aws events describe-rule \
  --name cost-governance-demo-eventbridge-alarm-trigger \
  --region us-east-2

# Verify event pattern matches CloudWatch alarm format
aws events put-events \
  --entries file://test-event.json \
  --region us-east-2
```

### ❌ Budget alert not triggering
**Cause:** AWS Budgets updates every 8-24 hours
**Fix:**
- For instant demo, manually trigger SSM automation 
- Alternatively, wait 24 hours for automatic budget detection

## 🧠 Notes
- **SSM Automation Runtime:** Uses Python 3.8 with boto3 for AWS SDK operations
- **Budget Alerts:** AWS Budgets updates every 8-24 hours (not real-time)
- **S3 Lifecycle:** Transitions to STANDARD_IA (30d) → GLACIER (90d) → Expiration (365d)
- **EventBridge Integration:** Direct trigger from CloudWatch alarms, SNS relay for Budget alerts
- **Always destroy main infrastructure before tearing down remote state bucket**
- **Demo optimized:** 1 instance + 1 volume + $2 budget for quick demonstration

## 🔧 What Could Be Improved
- Add **Trusted Advisor** integration (requires Business/Enterprise support plan)
- Implement **Lambda functions** for event-driven cleanup without approval
- Implement **auto-scheduling** for daily/weekly cleanup runs
- Add **Cost Anomaly Detection** for proactive cost spike alerts
- Create **custom Cost Explorer reports** with detailed savings analysis

## 🎯 Real-World Use Cases

1. **Dev/Test Environment Cleanup**
   - Automatically terminate idle development instances overnight
   - Delete unattached volumes from testing

2. **Cost Anomaly Response**
   - Trigger cleanup when budget thresholds exceeded
   - Prevent runaway cloud costs

4. **Multi-Account Governance**
   - Extend to AWS Organizations
   - Centralized cost optimization across accounts

