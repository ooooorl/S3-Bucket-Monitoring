# Production environment specific configuration
module "s3_bucket" {
  source = "../../modules/s3-bucket"

  bucket_name   = var.bucket_name
  env           = var.env
  force_destroy = false  # NEVER allow force destroy in prod
  allowed_roles = [var.role_arn]
  
  tags = {
    Owner       = var.owner
    Environment = "production"
    CostCenter  = "prod"
  }
}

module "iam_policies" {
  source = "../../modules/iam"

  policy_name_prefix = var.bucket_name
  bucket_name        = var.bucket_name
  env                = var.env
  bucket_resources   = [
    module.s3_bucket.bucket_arn,
    "${module.s3_bucket.bucket_arn}/*"
  ]
  role_names         = [basename(var.role_arn)]
  
  tags = {
    Owner = var.owner
  }
}