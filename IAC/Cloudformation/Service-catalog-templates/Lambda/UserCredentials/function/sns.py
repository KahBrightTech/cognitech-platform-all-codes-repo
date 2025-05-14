import boto3
import os
import json

def lambda_handler(event, context):
    sns = boto3.client('sns')
    topic_arn = os.environ['SNS_TOPIC_ARN']
    message = event.get('message', 'No report provided.')

    sns.publish(
        TopicArn=topic_arn,
        Subject='IAM Credential Age Report',
        Message=message
    )

    return {'status': 'SNS message sent'}
