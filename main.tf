provider "aws" {
  region = var.aws_region
}

# Create S3 bucket
resource "aws_s3_bucket" "bucket" {
  bucket = "${var.bucket_name}-${var.env}"

  force_destroy = var.env == "dev" ? true : false

  tags = {
    Name        = "${var.bucket_name}-${var.env}"
    Environment = var.env
    Owner       = var.owner
  }
}

# Enable versioning using the recommended resource
resource "aws_s3_bucket_versioning" "bucket_versioning" {
  bucket = aws_s3_bucket.bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Generate IAM policy document
data "aws_iam_policy_document" "readonly" {
  statement {
    effect = "Allow"

    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.bucket.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = [var.role_arn]
    }
  }
}

# Attach bucket policy
resource "aws_s3_bucket_policy" "readonly_policy" {
  bucket = aws_s3_bucket.bucket.id
  policy = data.aws_iam_policy_document.readonly.json
}