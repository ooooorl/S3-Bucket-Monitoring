# Dev environment specific configuration
# Every time someone updates your bucket policy, ACL, encryption, or versioning,
# CloudTrail records the event → EventBridge rule catches it → invokes Lambda → logs into CloudWatch (and optionally SNS).

# Note: Ensure CloudTrail is enabled in the account to capture S3 API calls.
module "s3_bucket" {
  source = "../../modules/s3-bucket"

  bucket_name   = var.bucket_name
  env           = var.env
  force_destroy = true # Allow force destroy in dev
  allowed_roles = [var.role_arn]

  tags = {
    Owner       = var.owner
    Environment = "development"
    CostCenter  = "dev"
  }
}

# IAM Policies for S3 Bucket Access
module "iam_policies" {
  source = "../../modules/iam"

  policy_name_prefix = var.bucket_name
  bucket_name        = var.bucket_name
  env                = var.env
  bucket_resources = [
    module.s3_bucket.bucket_arn,
    "${module.s3_bucket.bucket_arn}/*"
  ]
  role_names = [basename(var.role_arn)] # Extracts just the role name from ARN

  tags = {
    Owner = var.owner
  }
}

# Add monitoring module (Lambda + EventBridge + CloudTrail integration)
module "monitoring" {
  source          = "../../modules/monitoring"
  env             = var.env
  bucket_name     = var.bucket_name
  lambda_role_arn = module.iam_policies.lambda_role_arn

  tags = {
    Owner       = var.owner
    Environment = "Staging"
    CostCenter  = "dev"
  }
}