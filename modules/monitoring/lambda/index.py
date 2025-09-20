import os
import json
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)


def handler(event, context):
    """
    Lambda handler that logs S3 bucket-level changes (policy, ACL, encryption, etc.)
    into CloudWatch Logs, with focus on *who* made the change.
    """

    bucket_name = os.environ.get("BUCKET_NAME", "unknown")
    env = os.environ.get("ENVIRONMENT", "unknown")

    # CloudTrail event details
    detail = event.get("detail", {})
    user_identity = detail.get("userIdentity", {})
    event_name = detail.get("eventName", "unknown")
    event_time = detail.get("eventTime", "unknown")

    # Who made the change?
    actor_type = user_identity.get("type", "unknown")
    actor_arn = user_identity.get("arn", "unknown")
    source_ip = detail.get("sourceIPAddress", "unknown")
    user_agent = detail.get("userAgent", "unknown")

    logger.info("===== S3 Bucket Control Change Detected =====")
    logger.info(f"Environment: {env}")
    logger.info(f"Bucket: {bucket_name}")
    logger.info(f"Event: {event_name} at {event_time}")
    logger.info(f"Actor Type: {actor_type}")
    logger.info(f"Actor ARN: {actor_arn}")
    logger.info(f"Source IP: {source_ip}")
    logger.info(f"User Agent: {user_agent}")

    # Still keep the request metadata
    logger.info(f"Request ID: {context.aws_request_id}")
    logger.info(f"Function Name: {context.function_name}")
    logger.info(f"Function Version: {context.function_version}")
    logger.info(f"Memory Limit: {context.memory_limit_in_mb} MB")

    return {
        "statusCode": 200,
        "body": json.dumps({"message": "Bucket update logged successfully"})
    }
