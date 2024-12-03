sam build
sam deploy
export API_ENDPOINT=$(aws cloudformation describe-stacks --stack-name serverless-api-powertools --output text --query 'Stacks[0].Outputs[?OutputKey==`PowertoolsApi`].OutputValue')\necho "API endpoint: $API_ENDPOINT"
curl -s -w "\nHTTP Status Code: %{http_code}\n" "$API_ENDPOINT/orders"
aws dynamodb put-item \\n    --table-name OrdersWorkshop \\n    --item '{\n        "orderId": {"S": "12345"},\n        "customerName": {"S": "John Doe"},\n        "orderStatus": {"S": "Pending"},\n        "orderDate": {"S": "2024-10-29"},\n        "restaurantName": {"S": "Sushi Restaurant"},\n        "orderItems": {"L": [\n            {"M": {"name": {"S": "Sushi Roll"}, "quantity": {"N": "2"}}},\n            {"M": {"name": {"S": "Miso Soup"}, "quantity": {"N": "1"}}}\n        ]}\n    }'
aws dynamodb put-item \
    --table-name OrdersWorkshop \
    --item '{
        "orderId": {"S": "12345"},
        "customerName": {"S": "John Doe"},
        "orderStatus": {"S": "Pending"},
        "orderDate": {"S": "2024-10-29"},
        "restaurantName": {"S": "Sushi Restaurant"},
        "orderItems": {"L": [
            {"M": {"name": {"S": "Sushi Roll"}, "quantity": {"N": "2"}}},
            {"M": {"name": {"S": "Miso Soup"}, "quantity": {"N": "1"}}}
        ]}
    }'
curl -s -w "\nHTTP Status Code: %{http_code}\n" "$API_ENDPOINT/orders"
curl -s -w "\nHTTP Status Code: %{http_code}\n" "$API_ENDPOINT/orders/12345"
# Errors here ^ {"message": "Unsupported HTTP method"}
