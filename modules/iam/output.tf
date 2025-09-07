output "policy_arn" {
  description = "ARN of the created IAM policy"
  value       = aws_iam_policy.s3_access_policy.arn
}

output "policy_name" {
  description = "Name of the created IAM policy"
  value       = aws_iam_policy.s3_access_policy.name
}

output "attached_roles" {
  description = "List of roles the policy was attached to"
  value       = var.role_names
}