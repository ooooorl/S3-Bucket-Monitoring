resource "aws_iam_policy" "s3_access_policy" {
  name        = "${var.policy_name_prefix}-${var.env}-s3-access"
  description = "Allow S3 access on ${var.bucket_name}-${var.env}"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = var.s3_actions
        Resource = var.bucket_resources
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "s3_access_attachment" {
  count      = length(var.role_names)
  role       = var.role_names[count.index]
  policy_arn = aws_iam_policy.s3_access_policy.arn
}

# Lambda execution role attachment
resource "aws_iam_role" "lambda_exec" {
  name = "${var.env}-${var.bucket_name}-lambda-exec-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}