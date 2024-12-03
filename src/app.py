#####
# imports - app.py
#####
from aws_lambda_powertools.event_handler import APIGatewayRestResolver
from aws_lambda_powertools.utilities.typing import LambdaContext
from all_routes import router

#####
# Classes, functions and instances - app.py
#####
app = APIGatewayRestResolver()
app.include_router(router)

#####
# Lambda handler - app.py
#####
def lambda_handler(event: dict, context: LambdaContext) -> dict:
    return app.resolve(event, context)
