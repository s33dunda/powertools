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
