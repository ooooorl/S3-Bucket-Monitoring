variable "policy_name_prefix" {
  description = "Prefix for the IAM policy name"
  type        = string
  default     = "s3-bucket"
}

variable "bucket_name" {
  description = "Name of the S3 bucket this policy applies to"
  type        = string
}

variable "env" {
  description = "Deployment environment"
  type        = string
}

variable "s3_actions" {
  description = "List of S3 actions to allow"
  type        = list(string)
  default     = ["s3:PutObject", "s3:GetObject", "s3:ListBucket"]
}

variable "bucket_resources" {
  description = "List of bucket resource ARNs the policy applies to"
  type        = list(string)
}

variable "role_names" {
  description = "List of IAM role names to attach the policy to (just the role name, not ARN)"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags to apply to the IAM policy"
  type        = map(string)
  default     = {}
}