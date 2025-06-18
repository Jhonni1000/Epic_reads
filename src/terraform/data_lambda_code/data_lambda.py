import boto3
import uuid

def lambda_handler(event, context):
    table_name = 'Contact_us'
    dynamodb = boto3.resource('dynamodb')
    table = dynamodb.Table(table_name)

    request = [{
        'Name': 'Pravinmishra', 'Email-Id': 'contact@pravinmishra.in'
        }]

    with table.batch_writer() as batch_writer:
        for order in request:
            item = {
                'Customer_id': uuid.uuid4().hex,
                'Name' : order['Name'],
                'Email-Id' : order['Email-Id']
            }
            
            print("> batch writing: {}".format(order['Email-Id']))
            batch_writer.put_item(Item=item)

    result = f"Recieved! {len(request)} request through {table_name}."
    return {'message': result}