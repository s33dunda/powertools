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
# add powertools. see commits
sam build
sam deploy
export API_ENDPOINT=$(aws cloudformation describe-stacks --stack-name serverless-api-powertools --output text --query 'Stacks[0].Outputs[?OutputKey==`PowertoolsApi`].OutputValue')
echo "API endpoint: $API_ENDPOINT"
curl -s -w "\nHTTP Status Code: %{http_code}\n" "$API_ENDPOINT/orders"
curl -s -w "\nHTTP Status Code: %{http_code}\n" "$API_ENDPOINT/orders/12345"

# Add improvements
touch src/all_routes.py
# You now have a file containing only the defined routes. You may notice that you haven't imported the APIGatewayRestResolver in this file,
# and that's because you don't need it here. The focus is solely on defining the routes using the new Router() object, which you will later
# integrate into the app in the main file.
# You also have changed the decorator from @app.get to @router.get. This is because you are now using the Router object to define routes.
# Powertools merge routes
# Powertools can merge routes defined directly in APIGatewayRestResolver and in the Router object, applying the same precedence rules.
# However, for better organization, we recommend choosing one approach consistently throughout your project. This helps maintain clarity
# and reduces potential confusion in route management.
