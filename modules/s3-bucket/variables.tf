variable "bucket_name" {
  description = "Base name for the S3 bucket"
  type        = string
  validation {
    condition     = length(var.bucket_name) >= 3 && length(var.bucket_name) <= 63
    error_message = "Bucket name must be between 3 and 63 characters."
  }
}

variable "env" {
  description = "Deployment environment (dev, staging, prod, etc.)"
  type        = string
  validation {
    condition     = contains(["dev", "staging", "prod"], var.env)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

variable "force_destroy" {
  description = "Whether to force destroy the bucket when running terraform destroy (use with caution)"
  type        = bool
  default     = false
}

variable "allowed_roles" {
  description = "List of IAM role ARNs allowed to access the bucket"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Additional tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "owner" {
  description = "Owner of the resource"
  type        = string
  default     = "plaza.orly.omeles@gmail.com"
}