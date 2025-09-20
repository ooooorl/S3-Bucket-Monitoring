import json
import logging
import os


logger = logging.getLogger()
logger.setLevel(logging.INFO)


def handler(event, context):
    """
    Lambda handler that logs S3 bucket-level changes (policy, ACL, encryption, etc.)
    into CloudWatch Logs
    """
    bucket_name = os.environ.get("BUCKET_NAME", "unknown")
    env = os.environ.get("ENVIRONMENT", "unknown")

    logger.info("===== S3 Bucket Control Change Detected =====")
    logger.info(f"Environment: {env}")
    logger.info(f"Bucket: {bucket_name}")
    logger.info(f"Event Detail: {json.dumps(event)}")
    logger.info(f"Request ID: {context.aws_request_id}")
    logger.info(f"Log Group: {context.log_group_name}")
    logger.info(f"Log Stream: {context.log_stream_name}")
    logger.info(f"Function Name: {context.function_name}")
    logger.info(f"Function Version: {context.function_version}")
    logger.info(f"Memory Limit: {context.memory_limit_in_mb} MB")

    return {
        "statusCode": 200,
        "body": json.dumps({"message": "Bucket update logged successfully"})
    }