# 🛠️ **Terraform Remote State Monitoring & Alerting**

This infrastructure ensures **secure management of Terraform remote state** while also providing **real-time monitoring and alerts** whenever the S3 bucket policies (used for storing `terraform.tfstate`) are modified.  

---

## **Overview**  

The setup provides:  
- **Remote state storage** in S3 with state locking in DynamoDB.  
- **CloudTrail logging** of all S3 control plane API calls.  
- **EventBridge rules** to detect policy/ACL changes on the state bucket.  
- **Lambda function** to process events and log details.  
- **CloudWatch** for event logging and monitoring.  
- **SNS notifications** for alerting admins of changes (*optional*). 
- **CI/CD pipelines**:  
  - **Validation Pipeline** → Runs `terraform fmt`, `terraform validate`, and `terraform plan` for code review.  
  - **Apply Pipeline** → Runs `terraform apply` to deploy approved changes.  

---

## **Architecture** 

### 1. Terraform State Management  
- **S3 bucket (`terraform.tfstate`)**: Stores the Terraform remote state.  
- **DynamoDB table (`terraform-locks`)**: Provides state locking to prevent simultaneous `terraform apply`.  

### 2. Audit Logging with CloudTrail  
- All **control plane API calls** (e.g., `PutBucketPolicy`, `DeleteBucketPolicy`, `PutBucketAcl`) on the state bucket are logged in **CloudTrail**.  

### 3. Event Filtering with EventBridge  
- An **EventBridge Rule** filters for S3 events related to **bucket policy/ACL changes**.  
- Only relevant changes trigger downstream actions.  

### 4. Event Processing with Lambda  
- A **Lambda function** is triggered when a change is detected.  
- It:  
  - Fetches **old vs new policy/ACL**.  
  - Logs event details into **CloudWatch Logs**.  
  - Publishes a summary to **SNS** for notification.  

### 5. Notifications & Monitoring  
- **CloudWatch**: Stores detailed logs for audit and troubleshooting.  
- **SNS**: Sends alerts (email, Slack, etc.) to admins when critical changes happen.  

---

## **Security & Benefits**

Prevents **undetected tampering** of Terraform state bucket.  
Provides **audit trails** of who made what change.  
Sends **real-time alerts** for quick response.  
Ensures **safe collaboration** with DynamoDB locking.  
Automates deployments with **CI/CD pipelines** for both validation and apply stages.  

---
## **Workflow** 

1. Developer opens a pull request.  
   - Validation pipeline runs (`fmt`, `validate`, `plan`).  
   - Team reviews the `terraform plan` output.  

2. After approval, changes are merged to `main`.  
   - Apply pipeline runs (`terraform apply`).  
   - State is updated in **S3** and locked with **DynamoDB**.  

3. If someone modifies the **bucket policy** or **ACL** outside of Terraform:  
   - CloudTrail logs it.  
   - EventBridge filters the event.  
   - Lambda runs and logs details.  
   - CloudWatch stores the logs.  
   - SNS alerts admins.  

---

## **Future Enhancements**
- Store historical policies in **DynamoDB** for audit history.  
- Add **diff engine** in Lambda to highlight exactly what changed.  
- Integrate with **Security Hub** or **SIEM tools** for compliance.  