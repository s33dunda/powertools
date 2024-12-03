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
#
sam build
sam deploy
export API_ENDPOINT=$(aws cloudformation describe-stacks --stack-name serverless-api-powertools --output text --query 'Stacks[0].Outputs[?OutputKey==`PowertoolsApi`].OutputValue')
echo "API endpoint: $API_ENDPOINT"
curl -s -w "\nHTTP Status Code: %{http_code}\n" "$API_ENDPOINT/orders"
curl -s -w "\nHTTP Status Code: %{http_code}\n" "$API_ENDPOINT/orders/12345"
# Build and deploy like above
# Create an order
RESPONSE=$(curl -s -X POST "$API_ENDPOINT/orders" \
-H "Content-Type: application/json" \
-d '{
  "customerName": "John Daves",
  "orderStatus": "Pending",
  "restaurantName": "Sushi Restaurant",
  "orderItems": [
    {"name": "Sashimi", "quantity": 1, "price": 10},
    {"name": "Ceviche", "quantity": 1, "price": 50}
  ],
  "orderDate": "2024-10-30T10:00:00Z"
}')

# Print the full response body
echo "$RESPONSE"

# Extract and save the orderId to a variable
export ORDER_ID=$(echo "$RESPONSE" | jq -r '.orderId')

curl -s -w "\nHTTP Status Code: %{http_code}\n" "$API_ENDPOINT/orders"
# Retrive our new order
curl -s -w "\nHTTP Status Code: %{http_code}\n" "$API_ENDPOINT/orders/$ORDER_ID"
# Update our order
curl -s -w "\nHTTP Status Code: %{http_code}\n" \
-X PUT "$API_ENDPOINT/orders/$ORDER_ID" \
-H "Content-Type: application/json" \
-d '{
  "customerName": "Mari Lee",
  "orderItems": [
    {"name": "Spice tuna", "quantity": 1, "price": 1200},
    {"name": "Soy sauce", "quantity": 2, "price": 1}
  ],
  "orderDate": "2024-11-01T09:30:00Z",
  "orderStatus": "Processing"
}'

# delete the order
curl -s -w "\nHTTP Status Code: %{http_code}\n" \
-X DELETE "$API_ENDPOINT/orders/$ORDER_ID"

# verify
curl -s -w "\nHTTP Status Code: %{http_code}\n" "$API_ENDPOINT/orders/$ORDER_ID"

# Build with new response classes and auto serializing
#
export API_ENDPOINT=$(aws cloudformation describe-stacks --stack-name serverless-api-powertools --output text --query 'Stacks[0].Outputs[?OutputKey==`PowertoolsApi`].OutputValue')
echo "API endpoint: $API_ENDPOINT"

# Create new order
response=$(curl -s -D - -X POST "$API_ENDPOINT/orders" \
-H "Content-Type: application/json" \
-d '{
  "customerName": "John Daves",
  "orderStatus": "Pending",
  "restaurantName": "Sushi Restaurant",
  "orderItems": [
    {"name": "Sashimi", "quantity": 1, "price": 10},
    {"name": "Ceviche", "quantity": 1, "price": 50}
  ],
  "orderDate": "2024-10-30T10:00:00Z"
}')

# Extract HTTP Status Code
http_code=$(echo "$response" | grep HTTP | awk '{print $2}')
echo "HTTP Status Code: $http_code"

# Extract Location header
location=$(echo "$response" | grep -i Location | awk '{print $2}' | tr -d '\r')
echo "Location: $location"

# Extract and print the response body
body=$(echo "$response" | grep "orderId" )
echo "Body: $body"

# Extract and save the orderId to a variable
export ORDER_ID=$(echo "$body" | jq -r '.orderId')

# Delete
response=$(curl -s -D - -X DELETE "$API_ENDPOINT/orders/$ORDER_ID" \
-H "Content-Type: application/json")

# Extract HTTP Status Code
http_code=$(echo "$response" | grep HTTP | awk '{print $2}')
echo "HTTP Status Code: $http_code"

# Extract and print the response body
body=$(echo "$response" | grep "orderId" )
echo "Body: $body"

# retrieve
curl -s -w "\nHTTP Status Code: %{http_code}\n" "$API_ENDPOINT/orders/$ORDER_ID"

# build and deploy CORS config
export API_ENDPOINT=$(aws cloudformation describe-stacks --stack-name serverless-api-powertools --output text --query 'Stacks[0].Outputs[?OutputKey==`PowertoolsApi`].OutputValue')
echo "API endpoint: $API_ENDPOINT"
# test w/out correct origin
curl -I -X GET "$API_ENDPOINT/orders"

# test with correct
curl -I -X GET "$API_ENDPOINT/orders" -H "Origin: https://www.amazon.com"
# bad again
curl -I -X GET "$API_ENDPOINT/orders" -H "Origin: https://www.invalid-site.com"


## Introduce error handling
curl -s -w "\nHTTP Status Code: %{http_code}\n" \
-X POST "$API_ENDPOINT/orders" \
-H "Content-Type: application/json" \
-d '{"invalid json}'
# > {"message": "Internal server error"}
# HTTP Status Code: 502
# Not a nice error... not sure what's wrong here'
# Unhandled Exceptions in AWS Lambda
# Failing to handle exceptions in AWS Lambda functions is a bad practice that can lead to some issues:

# It forces AWS Lambda to restart the execution environment, as it can't determine if the error is permanent or temporary.
# This restart can result in increased cold starts, impacting performance.
# It may cause scaling up problems, especially under high load.
# Unhandled exceptions can make debugging more difficult and lead to unexpected behavior.
# Proper exception handling is crucial for maintaining the reliability and efficiency of your Lambda functions.

# build and deploy our new error handlers and test them
export API_ENDPOINT=$(aws cloudformation describe-stacks --stack-name serverless-api-powertools --output text --query 'Stacks[0].Outputs[?OutputKey==`PowertoolsApi`].OutputValue')
echo "API endpoint: $API_ENDPOINT"
curl -s -w "\nHTTP Status Code: %{http_code}\n" "$API_ENDPOINT/my_orders"

curl -s -w "\nHTTP Status Code: %{http_code}\n" \
-X POST "$API_ENDPOINT/orders" \
-H "Content-Type: application/json" \
-d '{"invalid json}'

# Additionally, the AWS Console logs now indicate where the error occurred, making debugging easier and allowing for better indexing by
# your log query tool.

# Build and deploy our observability improvements
export API_ENDPOINT=$(aws cloudformation describe-stacks --stack-name serverless-api-powertools --output text --query 'Stacks[0].Outputs[?OutputKey==`PowertoolsApi`].OutputValue')
echo "API endpoint: $API_ENDPOINT"
curl -s -w "\nHTTP Status Code: %{http_code}\n" "$API_ENDPOINT/orders/12345"
# Test ^^^ and then look at cloudwatch logs
# Cloudwatch logs insights query
# fields @timestamp, FunctionRequestId, @message, order_id, cold_start
# | sort @timestamp asc
# | filter ispresent(function_request_id)
# | limit 20
# Goto X_RAY to the the traces
# And goto cloudwatch metrics and see our new custom metrics for order_id
#

# Build and deploy with the new authorizer
api_id=$(aws apigateway get-rest-apis --query "items[?name=='serverless-api-powertools'].id" --output text)
authorizer_id=$(aws apigateway get-authorizers --rest-api-id $api_id --query "items[?name=='PowertoolsFunctionAuthorizer'].id" --output text)
aws apigateway update-authorizer --rest-api-id $api_id --authorizer-id $authorizer_id --patch-operations op=replace,path=/authorizerResultTtlInSeconds,value=0

export API_ENDPOINT=$(aws cloudformation describe-stacks --stack-name serverless-api-powertools --output text --query 'Stacks[0].Outputs[?OutputKey==`PowertoolsApi`].OutputValue')
echo "API endpoint: $API_ENDPOINT"

curl -s -w "\nHTTP Status Code: %{http_code}\n" "$API_ENDPOINT/orders/12345"

# Add admin user
aws dynamodb put-item \
    --table-name OrdersAPIPermissions \
    --item '{
        "userId": {"S": "Alice"},
        "userInfo": {"S": "eyJuYW1lIjoiQWxpY2UiLCJsZXZlbCI6ImFkbWluIiwiZXhwaXJhdGlvbl9kYXRlIjoiMjAyNS0xMi0zMCJ9"}
    }'

# Add regular user
aws dynamodb put-item \
    --table-name OrdersAPIPermissions \
    --item '{
        "userId": {"S": "Bob"},
        "userInfo": {"S": "eyJuYW1lIjoiQm9iIiwibGV2ZWwiOiJ1c2VyIiwiZXhwaXJhdGlvbl9kYXRlIjoiMjAyNS0xMi0zMCJ9"}
    }'

curl -s -w "\nHTTP Status Code: %{http_code}\n" "$API_ENDPOINT/orders/12345" -H "Authorization: eyJuYW1lIjoiQm9iIiwibGV2ZWwiOiJ1c2VyIiwiZXhwaXJhdGlvbl9kYXRlIjoiMjAyNS0xMi0zMCJ9"

curl -X POST "$API_ENDPOINT/orders" \
-H "Content-Type: application/json" \
-H "Authorization: eyJuYW1lIjoiQm9iIiwibGV2ZWwiOiJ1c2VyIiwiZXhwaXJhdGlvbl9kYXRlIjoiMjAyNS0xMi0zMCJ9" \
-d '{
  "customerName": "John Daves",
  "orderStatus": "Pending",
  "restaurantName": "Sushi Restaurant",
  "orderItems": [
    {"name": "Sashimi", "quantity": 1, "price": 10},
    {"name": "Ceviche", "quantity": 1, "price": 50}
  ],
  "orderDate": "2024-10-30T10:00:00Z"
}'
# User is not authorized? Yeah!! The API authorization is working as intended, confirming that Bob's token does not have permission to place an order.
# Let's test Alice's admin privileges by inserting an order

curl -X POST "$API_ENDPOINT/orders" \
-H "Content-Type: application/json" \
-H "Authorization: eyJuYW1lIjoiQWxpY2UiLCJsZXZlbCI6ImFkbWluIiwiZXhwaXJhdGlvbl9kYXRlIjoiMjAyNS0xMi0zMCJ9" \
-d '{
  "customerName": "John Daves",
  "orderStatus": "Pending",
  "restaurantName": "Sushi Restaurant",
  "orderItems": [
    {"name": "Sashimi", "quantity": 1, "price": 10},
    {"name": "Ceviche", "quantity": 1, "price": 50}
  ],
  "orderDate": "2024-10-30T10:00:00Z"
}'
