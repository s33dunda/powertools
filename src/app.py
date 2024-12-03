#####
# imports - app.py
#####
import json
import boto3
from boto3.dynamodb.conditions import Key
from uuid import uuid4
from decimal import Decimal

from aws_lambda_powertools.event_handler import APIGatewayRestResolver
from aws_lambda_powertools.utilities.typing.lambda_context import LambdaContext

#####
# Classes, functions and instances - app.py
#####
dynamodb = boto3.resource('dynamodb')
orders_table = dynamodb.Table('OrdersWorkshop')
app = APIGatewayRestResolver()

class DecimalEncoder(json.JSONEncoder):
    def default(self, obj):
        if isinstance(obj, Decimal):
            return float(obj)
        return super(DecimalEncoder, self).default(obj)

#####
# Get all orders method - app.py
#####
@app.get("/orders")
def get_all_orders():
    response = orders_table.scan()

    if len(response['Items']) > 0:
        return json.dumps(response['Items'], cls=DecimalEncoder)
    else:
        return {"message": "No orders found"}

#####
# Get order method - app.py
#####
@app.get("/orders/<order_id>")
def get_order(order_id: str):
    response = orders_table.get_item(Key={'orderId': order_id})

    if 'Item' in response:
        return json.dumps(response['Item'], cls=DecimalEncoder)
    else:
        return {"message": "Order not found"}

#####
# Lambda handler - app.py
#####
def lambda_handler(event: dict, context: LambdaContext) -> dict:
    return app.resolve(event, context)
