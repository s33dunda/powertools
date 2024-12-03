#####
# imports - all_routes.py
#####
from uuid import uuid4
import boto3
import json
from aws_lambda_powertools.event_handler.api_gateway import Router
from decimal import Decimal

#####
# Classes, functions and instances - all_routes.py
#####
dynamodb = boto3.resource('dynamodb')
orders_table = dynamodb.Table('OrdersWorkshop')
router = Router()

class DecimalEncoder(json.JSONEncoder):
    def default(self, obj):
        if isinstance(obj, Decimal):
            return float(obj)
        return super(DecimalEncoder, self).default(obj)

#####
# Get all orders method - all_routes.py
#####
@router.get("/orders")
def get_all_orders():
    response = orders_table.scan()

    if len(response['Items']) > 0:
        return json.dumps(response['Items'], cls=DecimalEncoder)
    else:
        return {"message": "No orders found"}

#####
# Get order method - all_routes.py
#####
@router.get("/orders/<order_id>")
def get_order(order_id: str):
    response = orders_table.get_item(Key={'orderId': order_id})

    if 'Item' in response:
        return json.dumps(response['Item'], cls=DecimalEncoder)
    else:
        return {"message": "Order not found"}
