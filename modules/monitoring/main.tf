# Provision a Lambda Function
resource "aws_lambda_function" "s3_control_logger" {
  function_name = "${var.env}-${var.bucket_name}-s3-control-logger"
  handler       = "index.handler"
  runtime       = "python3.13"
  role          = var.lambda_role_arn
  filename      = var.lambda_package

  environment {
    variables = {
      ENVIRONMENT = var.env
      BUCKET_NAME = var.bucket_name
    }
  }
}

# Provision an EventBridge Rule for S3 Bucket Policy Changes
# Using the default management event provided by AWS CloudTrail
resource "aws_cloudwatch_event_rule" "s3_bucket_policy_change" {
  name        = "${var.bucket_name}-policy-change"
  description = "Rule to capture S3 bucket policy changes"
  
  event_pattern = jsonencode({
    source = ["aws.s3"]
    detail-type = ["AWS API Call via CloudTrail"]
    detail = {
      eventSource = ["s3.amazonaws.com"]
      eventName = [
        "PutBucketPolicy", 
        "DeleteBucketPolicy", 
        "PutBucketAcl", 
        "PutBucketCors", 
        "PutBucketLogging", 
        "PutBucketVersioning"
      ]

      # Enable this to capture specific bucket
    #   requestParameters = {
    #     bucketName = [var.bucket_name]
    #   }
    }
  })
}

# Event Target to invoke Lambda on rule match
resource "aws_cloudwatch_event_target" "send_to_lambda" {
  rule      = aws_cloudwatch_event_rule.s3_bucket_policy_change.name
  target_id = "SendToLambda"
  arn       = aws_lambda_function.s3_control_logger.arn
}

# Permission for EventBridge to invoke Lambda
resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.s3_control_logger.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.s3_bucket_policy_change.arn
}