resource "aws_s3_bucket" "this" {
  bucket = "${var.bucket_name}-${var.env}"

  force_destroy = var.force_destroy

  tags = merge(var.tags, {
    Name        = "${var.bucket_name}-${var.env}"
    Owner       = var.owner
    Environment = var.env
  })
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Add caller identity for CloudTrail bucket policy
# Pulls your AWS account ID automatically
# This is inserted into the bucket policy for the log path (AWSLogs/<account-id>).
data "aws_caller_identity" "current" {}

resource "aws_s3_bucket_policy" "this" {
  bucket = aws_s3_bucket.this.id
  policy = data.aws_iam_policy_document.bucket_policy.json
}

data "aws_iam_policy_document" "bucket_policy" {
  # ListBucket applies to the bucket ARN
  statement {
    effect = "Allow"
    actions   = ["s3:ListBucket"]
    resources = [aws_s3_bucket.this.arn]

    principals {
      type        = "AWS"
      identifiers = var.allowed_roles
    }
  }

  # GetObject and PutObject apply to objects under the bucket
  statement {
    effect = "Allow"
    actions   = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
    resources = ["${aws_s3_bucket.this.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = var.allowed_roles
    }
  }

  # Allow CloudTrail to write logs to this bucket
  # CloudTrail always checks bucket ACLs before writing.
  statement {
    sid     = "AWSCloudTrailAclCheck"
    effect  = "Allow"
    actions = ["s3:GetBucketAcl"]
    resources = [aws_s3_bucket.this.arn]

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
  }

  statement {
    sid     = "AWSCloudTrailWrite"
    effect  = "Allow"
    actions = ["s3:PutObject"]
    resources = [
      "${aws_s3_bucket.this.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"
    ]

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    # The condition ensures logs are written with ACL = bucket-owner-full-control (so you never lose ownership).
    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
  }
}

# This block prevents public access to the S3 bucket
resource "aws_s3_bucket_public_access_block" "cloudtrail_logs" {
  bucket                  = aws_s3_bucket.this.id   # replace aws_s3_bucket.this with your bucket resource
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}