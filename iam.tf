# Custom IAM policy to allow PutObject on this bucket
resource "aws_iam_policy" "put_object_policy" {
  name        = "${var.bucket_name}-${var.env}-put-object"
  description = "Allow PutObject on ${var.bucket_name}-${var.env}"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.bucket.arn}/*"
      }
    ]
  })
}

# Attach the custom policy to the IAM role
resource "aws_iam_role_policy_attachment" "attach_put_object" {
  role       = basename(var.role_arn)
  policy_arn = aws_iam_policy.put_object_policy.arn
}