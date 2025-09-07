# Terraform backend configuration
terraform {
  backend "s3" {
    bucket         = "tf-bckt-stg"               # Dedicated bucket
    key            = "staging/terraform.tfstate" # Path within the bucket
    region         = "ap-southeast-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}