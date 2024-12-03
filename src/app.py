#####
# imports - app.py
#####
from aws_lambda_powertools.event_handler import APIGatewayRestResolver, CORSConfig
from aws_lambda_powertools.utilities.typing import LambdaContext
from all_routes import router

#####
# Classes, functions and instances - app.py
#####
cors_config = CORSConfig(allow_origin="https://www.amazon.com", max_age=300)
app = APIGatewayRestResolver(cors=cors_config)
app.include_router(router)

#####
# Lambda handler - app.py
#####
def lambda_handler(event: dict, context: LambdaContext) -> dict:
    return app.resolve(event, context)
