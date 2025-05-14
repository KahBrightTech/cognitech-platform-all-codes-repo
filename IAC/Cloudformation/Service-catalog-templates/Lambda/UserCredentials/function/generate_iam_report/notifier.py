import boto3

def send_sns_notification(topic_arn, message):
    sns = boto3.client('sns')
    sns.publish(
        TopicArn=topic_arn,
        Message=message,
        Subject='Weekly IAM Credential Report'
    )
