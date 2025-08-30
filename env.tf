variable "bucket_name" {
  description = "S3 bucket name"
  type        = string
}

variable "role_arn" {
  description = "IAM Role ARN that can read the S3 bucket"
  type        = string
}

variable "aws_region" {
  description = "AWS region to deploy to"
  type        = string
  default     = "ap-southeast-1"
}

variable "env" {
  description = "Deployment environment (dev/prod/etc.)"
  type        = string
  default     = "dev"
}

variable "owner" {
  description = "Owner of the resource"
  type        = string
  default     = "plaza.orly.omeles@gmail.com"
}