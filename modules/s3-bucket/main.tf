# ###############################################
# # S3 bucket for storing CloudTrail logs
# ###############################################
# # Create the S3 bucket that will store CloudTrail logs
# # force_destroy allows Terraform to delete the bucket even if it contains objects
# resource "aws_s3_bucket" "this" {
#   bucket = "${var.bucket_name}-${var.env}"

#   force_destroy = var.force_destroy

#   tags = merge(var.tags, {
#     Name        = "${var.bucket_name}-${var.env}"
#     Owner       = var.owner
#     Environment = var.env
#   })
# }

# # Enable versioning so previous log files are preserved if they are ever overwritten
# resource "aws_s3_bucket_versioning" "this" {
#   bucket = aws_s3_bucket.this.id

#   versioning_configuration {
#     status = "Enabled"
#   }
# }

# # Add caller identity for CloudTrail bucket policy
# # Pulls your AWS account ID automatically
# # Fetch the current AWS Account ID (used to restrict CloudTrail writes to AWSLogs/<account-id>/*)
# data "aws_caller_identity" "current" {}

# ###############################################
# # Bucket Policy
# ###############################################
# # Attach a bucket policy that allows:
# #  - Specific IAM roles to access the bucket/objects
# #  - CloudTrail service to write logs into this bucket securely
# resource "aws_s3_bucket_policy" "this" {
#   bucket = aws_s3_bucket.this.id
#   policy = data.aws_iam_policy_document.bucket_policy.json
# }

# # Define bucket policy statements
# data "aws_iam_policy_document" "bucket_policy" {
#    # Allow specified IAM roles to list bucket contents
#   statement {
#     effect = "Allow"
#     actions   = ["s3:ListBucket"]
#     resources = [aws_s3_bucket.this.arn]

#     principals {
#       type        = "AWS"
#       identifiers = var.allowed_roles
#     }
#   }

#   # GetObject and PutObject apply to objects under the bucket
#   statement {
#     effect = "Allow"
#     actions   = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
#     resources = ["${aws_s3_bucket.this.arn}/*"]

#     principals {
#       type        = "AWS"
#       identifiers = var.allowed_roles
#     }
#   }

#   # Allow CloudTrail to write logs to this bucket
#   # CloudTrail always checks bucket ACLs before writing.
#   statement {
#     sid     = "AWSCloudTrailAclCheck"
#     effect  = "Allow"
#     actions = ["s3:GetBucketAcl"]
#     resources = [aws_s3_bucket.this.arn]

#     principals {
#       type        = "Service"
#       identifiers = ["cloudtrail.amazonaws.com"]
#     }
#   }

#   statement {
#     sid     = "AWSCloudTrailWrite"
#     effect  = "Allow"
#     actions = ["s3:PutObject"]
#     resources = [
#       "${aws_s3_bucket.this.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"
#     ]

#     principals {
#       type        = "Service"
#       identifiers = ["cloudtrail.amazonaws.com"]
#     }

#     # The condition ensures logs are written with ACL = bucket-owner-full-control (so you never lose ownership).
#     condition {
#       test     = "StringEquals"
#       variable = "s3:x-amz-acl"
#       values   = ["bucket-owner-full-control"]
#     }
#   }
# }

# # This block prevents public access to the S3 bucket
# resource "aws_s3_bucket_public_access_block" "cloudtrail_logs" {
#   bucket                  = aws_s3_bucket.this.id   # replace aws_s3_bucket.this with your bucket resource
#   block_public_acls       = true
#   block_public_policy     = true
#   ignore_public_acls      = true
#   restrict_public_buckets = true
# }


###############################################
# S3 bucket for storing CloudTrail logs
###############################################

# Create the S3 bucket that will store CloudTrail logs.
# force_destroy allows Terraform to delete the bucket even if it contains objects.
resource "aws_s3_bucket" "this" {
  bucket = "${var.bucket_name}-${var.env}"

  force_destroy = var.force_destroy

  tags = merge(var.tags, {
    Name        = "${var.bucket_name}-${var.env}"
    Owner       = var.owner
    Environment = var.env
  })
}

# Enable versioning so previous log files are preserved
# if they are ever overwritten. This helps maintain an immutable audit trail.
resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Fetch the current AWS Account ID.
# Used later to scope CloudTrail writes to AWSLogs/<account-id>/*
data "aws_caller_identity" "current" {}

###############################################
# Bucket Policy
###############################################

# Attach a bucket policy that:
#  - Allows specific IAM roles to access the bucket/objects
#  - Grants CloudTrail service permissions to write logs securely
resource "aws_s3_bucket_policy" "this" {
  bucket = aws_s3_bucket.this.id
  policy = data.aws_iam_policy_document.bucket_policy.json
}

# Define bucket policy statements
data "aws_iam_policy_document" "bucket_policy" {
  # Allow specified IAM roles to list bucket contents
  statement {
    effect    = "Allow"
    actions   = ["s3:ListBucket"]
    resources = [aws_s3_bucket.this.arn]

    principals {
      type        = "AWS"
      identifiers = var.allowed_roles
    }
  }

  # Allow specified IAM roles to read/write/delete objects in the bucket
  statement {
    effect    = "Allow"
    actions   = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
    resources = ["${aws_s3_bucket.this.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = var.allowed_roles
    }
  }

  # Allow CloudTrail to check the bucket ACL
  # CloudTrail always checks bucket ACLs before writing.
  statement {
    sid       = "AWSCloudTrailAclCheck"
    effect    = "Allow"
    actions   = ["s3:GetBucketAcl"]
    resources = [aws_s3_bucket.this.arn]

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
  }

  # Allow CloudTrail to write logs into AWSLogs/<account-id>/*
  # The condition enforces that logs are written with bucket-owner-full-control ACL.
  statement {
    sid       = "AWSCloudTrailWrite"
    effect    = "Allow"
    actions   = ["s3:PutObject"]
    resources = [
      "${aws_s3_bucket.this.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"
    ]

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
  }
}

###############################################
# Public Access Protection
###############################################

# Block all forms of public access to this bucket.
# Security best practice: CloudTrail log buckets must never be public.
resource "aws_s3_bucket_public_access_block" "cloudtrail_logs" {
  bucket                  = aws_s3_bucket.this.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
