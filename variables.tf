variable "aws_region" {
  description = "AWS region to deploy to"
  type        = string
  default     = "ap-southeast-1"
}

# Common variables that might be used across environments
variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default = {
    Project   = "my-archlinux-terraform"
    ManagedBy = "Terraform"
  }
}