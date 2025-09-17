# Provision a Cloudtrail Trail for S3 Bucket Policy Changes (Automatically send to EventBridge)
resource "aws_cloudtrail" "s3_policy_trail" {
  name                          = "${var.env}-${var.bucket_name}-s3-policy-trail"
  s3_bucket_name                = var.cloudtrail_logs_bucket_name
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_log_file_validation    = true

  event_selector {
    read_write_type           = "All"
    include_management_events = true
  }
}


# Automatically zip the Lambda function code
resource "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda"
  output_path = "${path.module}/s3-monitoring-lambda.zip"
}

# Provision a Lambda Function
resource "aws_lambda_function" "s3_control_logger" {
  function_name = "${var.env}-${var.bucket_name}-s3-control-logger"
  handler       = "index.handler"
  runtime       = "python3.13"
  role          = var.lambda_role_arn
  filename      = archive_file.lambda_zip.output_path

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
        "PutBucketPolicy",      # These are the events that changes bucket policies
        "DeleteBucketPolicy",   # If it happens, It will then trigger the cloudtrail once these events occur
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

# Connect the EventBridge Rule to the Lambda Function
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