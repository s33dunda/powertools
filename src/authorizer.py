#####
# imports - authorizer.py
#####
import base64
import json
from aws_lambda_powertools.utilities.data_classes import event_source
from aws_lambda_powertools.utilities.data_classes.api_gateway_authorizer_event import (
    APIGatewayAuthorizerTokenEvent,
    APIGatewayAuthorizerResponse,
)
from aws_lambda_powertools import Logger
import boto3
import re

#####
# Classes, functions and instances - authorizer.py
#####
logger = Logger()

dynamodb = boto3.resource('dynamodb')
auth_table = dynamodb.Table('OrdersAPIPermissions')

def validate_token(policy: APIGatewayAuthorizerResponse, token: str, resource: str):
  try:
      decoded_token = json.loads(base64.b64decode(token).decode('utf-8'))
      user_name = decoded_token.get("name")

      user_data = auth_table.get_item(Key={'userId': user_name}).get('Item', {})

      if not user_data:
          logger.error(f"User {user_name} not found in database")
          policy.deny_all_routes()
          return policy.asdict()

      if decoded_token['level'] == "admin":
          logger.info(f"Admin access granted for {user_name}")
          policy.allow_all_routes()

      if decoded_token['level'] == "user":
          logger.info(f"User access granted for {user_name}")
          policy.allow_route("GET", "orders/*")
          policy.allow_route("GET", "orders_per_restaurant/*")
          policy.deny_route("POST", "orders")
          policy.deny_route("PUT", "orders")
          policy.deny_route("DELETE", "orders")

      return policy.asdict()

  except Exception as e:
        logger.exception(f"Error validating token: {str(e)}")
        raise Exception("Error validating token")

#####
# Lambda handler - authorizer.py
#####
@event_source(data_class=APIGatewayAuthorizerTokenEvent)
def lambda_handler(event: APIGatewayAuthorizerTokenEvent, context):
    arn = event.parsed_arn

    policy = APIGatewayAuthorizerResponse(
        principal_id="user",
        region=arn.region,
        aws_account_id=arn.aws_account_id,
        api_id=arn.api_id,
        stage=arn.stage
    )

    return validate_token(policy=policy, token=event.authorization_token, resource=arn.resource)
