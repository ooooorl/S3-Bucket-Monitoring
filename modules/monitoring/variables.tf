variable "env" {
  description = "Environment name (staging/prod/etc.)"
  type        = string
}

variable "bucket_name" {
  description = "S3 bucket name"
  type        = string
}

variable "lambda_role_arn" {
  description = "IAM role ARN for Lambda execution"
  type        = string
}

variable "lambda_package" {
  description = "Path to Lambda deployment package (zip)"
  type        = string
}

variable "enable_sns" {
  description = "Whether to enable SNS alerts"
  type        = bool
  default     = false
}

variable "alert_subscriptions" {
  description = "SNS subscriptions (protocol + endpoint)"
  type = list(object({
    protocol = string
    endpoint = string
  }))
  default = []
}

variable "tags" {
  description = "Tags to apply to monitoring resources"
  type        = map(string)
  default     = {}
}