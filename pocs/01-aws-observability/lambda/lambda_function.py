import json
import boto3
import os
from http import HTTPStatus

from aws_lambda_powertools.utilities.typing import LambdaContext
from aws_lambda_powertools import Logger, Tracer, Metrics
from aws_lambda_powertools.event_handler import APIGatewayRestResolver
from aws_lambda_powertools.metrics import MetricUnit
from aws_lambda_powertools.logging import correlation_paths

# Initialize AWS services
dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table(os.getenv("DYNAMODB_TABLE", "COE-AWS-OBS-DynamoDB-Table"))

# Initialize Powertools
app = APIGatewayRestResolver()
service = "coe-aws-obs-lambda"
tracer = Tracer(service=service)
logger = Logger(service=service)
metrics = Metrics(namespace=service)

@tracer.capture_method
@app.get("/test/<id>")
def get_item(id: str):
    """Retrieve an item from DynamoDB by ID"""
    event = app.current_event.raw_event
    logger.debug({"topic": "get_item", "event": event, "request_id": id})

    if not id:
        return create_response(event, HTTPStatus.BAD_REQUEST, {"id": id}, "Missing required 'id' parameter")

    try:
        logger.info({"operation": "get_item", "id": id})
        response = table.get_item(Key={"Id": id})

        if "Item" in response:
            metrics.add_metric(name="GetItemOperations", unit=MetricUnit.Count, value=1)
            return create_response(event, HTTPStatus.OK, {"id": id}, response["Item"])
        
        return create_response(event, HTTPStatus.NOT_FOUND, {"id": id}, f"Item with ID {id} not found")
    
    except Exception as e:
        return handle_exception(event, "get_item", e)

@tracer.capture_method
@app.post("/test")
def put_item():
    """Add a new item to DynamoDB"""
    event = app.current_event.raw_event
    logger.debug({"topic": "put_item", "event": event})

    try:
        body = json.loads(event.get("body", "{}"))
        
        if not isinstance(body, dict) or "Id" not in body or "Name" not in body:
            return create_response(event, HTTPStatus.BAD_REQUEST, body, "Invalid request: 'Id' and 'Name' fields are required")

        logger.info({"operation": "put_item", "item": body})
        table.put_item(Item=body)
        metrics.add_metric(name="PutItemOperations", unit=MetricUnit.Count, value=1)
        
        return create_response(event, HTTPStatus.ACCEPTED, body, {"message": "Item created successfully", "id": body["Id"]})
    
    except json.JSONDecodeError:
        return create_response(event, HTTPStatus.BAD_REQUEST, event.get("body"), "Invalid JSON in request body")
    
    except Exception as e:
        return handle_exception(event, "put_item", e)

@tracer.capture_method
def get_status_code_from_header(event):
    """Extract custom status code from header if present"""
    headers = event.get("headers", {})
    
    if headers and "x-coe-obs-status-code" in headers:
        try:
            return int(headers["x-coe-obs-status-code"])
        except (ValueError, TypeError):
            logger.warning({"message": "Invalid x-coe-obs-status-code header value"})

    return None

@tracer.capture_method
def create_response(event, status_code: int, request_data: any, response_data: any):
    """Generate a standardized API response with CORS headers"""
    response_body = {
        "request": request_data,
        "response": response_data if isinstance(response_data, dict) else {"message": response_data}
    }

    response = {
        "statusCode": get_status_code_from_header(event) or status_code,
        "headers": {
            "Access-Control-Allow-Origin": "*",
            "Access-Control-Allow-Headers": "Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Coe-Obs-Status-Code",
            "Access-Control-Allow-Methods": "GET,POST,OPTIONS",
        },
        "body": response_body
    }
    
    log_query("lambda_result", response)
    return response, response["statusCode"]

@tracer.capture_method
def handle_exception(event, operation: str, error: Exception):
    """Handle exceptions with logging and metrics"""
    error_message = f"Error in {operation}: {str(error)}"
    logger.error({"operation": operation, "error": str(error), "event": event})
    metrics.add_metric(name="FailedOperations", unit=MetricUnit.Count, value=1)

    return create_response(event, HTTPStatus.INTERNAL_SERVER_ERROR, {"operation": operation}, error_message)

@tracer.capture_method
def log_query(value: str, log_message: any):
    """Log the query with a custom message"""
    key = "log_query"
    logger.append_keys(**{key: value})
    logger.info(log_message)
    logger.remove_keys([key])

# Lambda handler
@logger.inject_lambda_context(log_event=False, clear_state=True, correlation_id_path=correlation_paths.API_GATEWAY_REST)
@tracer.capture_lambda_handler
def lambda_handler(event: dict, context: LambdaContext) -> dict:
    logger.append_keys(http_method=event.get("httpMethod", "UNKNOWN"))

    if event.get("httpMethod") not in {"GET", "POST"}:
        return create_response(event, HTTPStatus.METHOD_NOT_ALLOWED, event, "Method not allowed")

    return app.resolve(event, context)