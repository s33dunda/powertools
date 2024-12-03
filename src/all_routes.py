#####
# imports - all_routes.py
#####
from http import HTTPStatus
from uuid import uuid4
import boto3
import json
from aws_lambda_powertools import Logger, Metrics, Tracer
from aws_lambda_powertools.metrics import MetricUnit
from aws_lambda_powertools.event_handler.api_gateway import Router
from aws_lambda_powertools.event_handler import (
    Response,
    content_types,
)

#####
# Classes, functions and instances - all_routes.py
#####
dynamodb = boto3.resource('dynamodb')
orders_table = dynamodb.Table('OrdersWorkshop')
router = Router()

logger = Logger()
metrics = Metrics()
tracer = Tracer()
#####
# Get all orders method - all_routes.py
#####
@router.get("/orders")
def get_all_orders():
    response = orders_table.scan()

    if len(response['Items']) > 0:
        return Response(
            status_code=HTTPStatus.OK.value,  # HTTP CODE 200
            content_type=content_types.APPLICATION_JSON,
            body=response['Items'],
        )
    else:
        return Response(
            status_code=HTTPStatus.NOT_FOUND.value,  # HTTP CODE 404
            content_type=content_types.APPLICATION_JSON,
            body={"message": "No orders found"},
        )
#####
# Get order method - all_routes.py
#####
@router.get("/orders/<order_id>")
@tracer.capture_method
def get_order(order_id: str):
    response = orders_table.get_item(Key={'orderId': order_id})

    # Logging
    logger.info("Searching an order", order_id=order_id)

    # Adding metric
    metrics.add_dimension(name="order_id", value=order_id)
    metrics.add_metric("OrderSearch", unit=MetricUnit.Count, value=1)

    if 'Item' in response:
        return Response(
            status_code=HTTPStatus.OK.value,  # HTTP CODE 200
            content_type=content_types.APPLICATION_JSON,
            body=response['Item'],
        )
    else:
        return Response(
            status_code=HTTPStatus.NOT_FOUND.value,  # HTTP CODE 404
            content_type=content_types.APPLICATION_JSON,
            body={"message": "Order not found"}
        )

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

    return Response(
        status_code=HTTPStatus.CREATED.value,  # HTTP CODE 201
        content_type=content_types.APPLICATION_JSON,
        headers={"Location": f"/orders/{order_id}"},
        body=item,
    )

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

    return Response(
        status_code=HTTPStatus.OK.value,  # HTTP CODE 200
        content_type=content_types.APPLICATION_JSON,
        body=response['Attributes'],
    )

#####
# Delete order method - all_routes.py
#####
@router.delete("/orders/<order_id>")
def delete_order(order_id: str):
    orders_table.delete_item(Key={'orderId': order_id})

    return Response(
        status_code=HTTPStatus.NO_CONTENT.value,  # HTTP CODE 204
        content_type=content_types.APPLICATION_JSON,
    )
