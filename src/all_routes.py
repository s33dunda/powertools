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

#####
# Create order method - all_routes.py
#####
@router.post("/orders")
def create_order():
    body = router.current_event.json_body
    order_id = str(uuid4())

    item = {
        'orderId': order_id,
        'customerName': body.get('customerName'),
        "restaurantName": body.get('restaurantName'),
        'orderItems': body.get('orderItems'),
        'orderDate': body.get('orderDate'),
        'orderStatus': 'Pending',
    }

    orders_table.put_item(Item=item)

    return json.dumps(item, cls=DecimalEncoder)

#####
# Update order method - all_routes.py
#####
@router.put("/orders/<order_id>")
def update_order(order_id: str):
    body = router.current_event.json_body

    response = orders_table.update_item(
        Key={'orderId': order_id},
        UpdateExpression='SET customerName = :name, orderItems = :items, orderDate = :date, orderStatus = :status',
        ExpressionAttributeValues={
            ':name': body.get('customerName'),
            ':items': body.get('orderItems'),
            ':date': body.get('orderDate'),
            ':status': body.get('orderStatus'),
        },
        ReturnValues='ALL_NEW'
    )

    return json.dumps(response['Attributes'], cls=DecimalEncoder)

#####
# Delete order method - all_routes.py
#####
@router.delete("/orders/<order_id>")
def delete_order(order_id: str):
    orders_table.delete_item(Key={'orderId': order_id})

    return {"message": "Order deleted"}
