variable "role_arn" {
  description = "IAM Role ARN that can access the S3 bucket"
  type        = string
  sensitive   = true
}

variable "bucket_name" {
  description = "S3 bucket base name (will be appended with environment)"
  type        = string
}

variable "aws_region" {
  description = "AWS region to deploy to"
  type        = string
  default     = "ap-southeast-1"
}

variable "env" {
  description = "Deployment environment"
  type        = string
}

variable "owner" {
  description = "Owner of the resource"
  type        = string
}

# Enable this if you already have a lambda role created manually
# variable "lambda_role_arn" {
#   description = "IAM Role ARN assumed by the monitoring Lambda"
#   type        = string
# }

# variable "lambda_package" {
#   description = "Path to the Lambda deployment package (zip file)"
#   type        = string
#   default     = "../../lambda/s3-monitoring-lambda.zip"
# }