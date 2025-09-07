provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project    = "my-archlinux-terraform"
      ManagedBy  = "Terraform"
      Repository = "https://github.com/ooooorl/Terraform"
    }
  }
}