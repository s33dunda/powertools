#####
# imports - app.py
#####
from http import HTTPStatus
from aws_lambda_powertools.event_handler import APIGatewayRestResolver, CORSConfig
from aws_lambda_powertools.event_handler import (
    Response,
    content_types,
)
from aws_lambda_powertools.utilities.typing import LambdaContext
from aws_lambda_powertools.event_handler.exceptions import NotFoundError
from aws_lambda_powertools import Logger
from all_routes import router

#####
# Classes, functions and instances - app.py
#####
logger = Logger()

cors_config = CORSConfig(allow_origin="https://www.amazon.com", max_age=300)
app = APIGatewayRestResolver(cors=cors_config)
app.include_router(router)

@app.exception_handler([ValueError, AttributeError])
def handle_invalid_payload(ex: ValueError | AttributeError):
    metadata = {"path": app.current_event.path, "http_method": app.current_event.http_method}
    logger.exception(f"Malformed request: {ex}", metadata=metadata)

    return Response(
        status_code=HTTPStatus.BAD_REQUEST.value,
        content_type=content_types.APPLICATION_JSON,
        body={"message": "Invalid request parameters. Please verify your parameters or payload according to our documentation."}
    )

@app.not_found
def handle_not_found_errors(exc: NotFoundError) -> Response:
    logger.info(f"Route not found: {app.current_event.path}")
    return Response(status_code=HTTPStatus.NOT_FOUND.value, content_type=content_types.TEXT_PLAIN, body="Sorry, I don't exist!")

#####
# Lambda handler - app.py
#####
def lambda_handler(event: dict, context: LambdaContext) -> dict:
    return app.resolve(event, context)
