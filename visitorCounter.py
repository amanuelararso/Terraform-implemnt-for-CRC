import json
import boto3
from decimal import Decimal

def decimal_default(obj):
    if isinstance(obj, Decimal):
        return float(obj)
    raise TypeError

def lambda_handler(event, context):
    dynamodb = boto3.resource('dynamodb')
    table = dynamodb.Table('visitorCount')
    
    # Initialize the visitor count if it doesn't exist
    response = table.get_item(Key={'id': 'visitor_count'})
    if 'Item' not in response:
        table.put_item(Item={'id': 'visitor_count', 'count': 0})
    
    # Increment the visitor count
    response = table.update_item(
        Key={'id': 'visitor_count'},
    UpdateExpression='SET #count = #count + :incr',
    ExpressionAttributeNames={'#count': 'count'},
    ExpressionAttributeValues={':incr': 1},
    ReturnValues='UPDATED_NEW'
    )
    
    # Get the updated count
    new_count = response['Attributes']['count']
    
    return {
        'statusCode': 200,
        'body': json.dumps({'visitor_count': new_count}, default=decimal_default)
    }
