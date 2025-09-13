output "lambda_arn" {
  description = "ARN of the monitoring Lambda"
  value       = aws_lambda_function.s3_control_logger.arn
}

# output "sns_topic_arn" {
#   description = "SNS Topic ARN (if enabled)"
#   value       = try(aws_sns_topic.alerts[0].arn, null)
# }
