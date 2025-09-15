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
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.this.arn}/*"]
    # actions   = ["s3:GetObject", "s3:PutObject"]

    principals {
      type        = "AWS"
      identifiers = var.allowed_roles
    }
  }
}