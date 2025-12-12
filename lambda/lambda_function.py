import uuid
import json
import boto3
import os
import logging
from datetime import datetime


TABLE_NAME = os.environ.get("REQUESTS_TABLE", "unknown-table")

dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table(TABLE_NAME)

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    # Incoming event logging
    logger.info("Received event: %s", json.dumps(event))

    # Create request id
    request_id = str(uuid.uuid4())
    item = {
        "id": request_id,
        "timestamp": datetime.now().isoformat() + "Z",
        "event": event
    }

    # Save request to DynamoDB
    try:
        table.put_item(Item=item)
        logger.info("Saved item %s to %s", request_id, TABLE_NAME)
    except Exception as e:
        logger.exception("Failed to write to DynamoDB: %s", e)
        return {
            "statusCode": 500,
            "body": json.dumps({"status": "error", "message": "Failed saving request."}),
            "headers": {"Content-Type": "application/json"}
        }

    # Return success
    return {
        "statusCode": 200,
        "body": json.dumps({"status": "healthy", "message": "Request processed and saved.", "id": request_id}),
        "headers": {"Content-Type": "application/json"}
    }
