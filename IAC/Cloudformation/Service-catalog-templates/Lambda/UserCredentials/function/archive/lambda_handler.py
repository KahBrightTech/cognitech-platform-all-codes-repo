import boto3
import os
from notifier import send_sns_notification

def lambda_handler(event, context):
    iam = boto3.client('iam')

    # Step 1: List all IAM users
    users = iam.list_users()['Users']

    report_lines = []
    for user in users:
        username = user['UserName']
        access_keys = iam.list_access_keys(UserName=username)['AccessKeyMetadata']

        for key in access_keys:
            key_id = key['AccessKeyId']
            create_date = key['CreateDate']
            last_used_info = iam.get_access_key_last_used(AccessKeyId=key_id)

            last_used_date = last_used_info['AccessKeyLastUsed'].get('LastUsedDate', 'Never used')
            region = last_used_info['AccessKeyLastUsed'].get('Region', 'N/A')
            service = last_used_info['AccessKeyLastUsed'].get('ServiceName', 'N/A')

            report_lines.append(
                f"User: {username}, KeyID: {key_id}, Created: {create_date}, "
                f"LastUsed: {last_used_date}, Region: {region}, Service: {service}"
            )

    if report_lines:
        message_body = "IAM Credential Report:\n\n" + "\n".join(report_lines)
    else:
        message_body = "IAM Credential Report: No users or keys found."

    # Step 2: Send the notification
    topic_arn = os.environ['SNS_TOPIC_ARN']
    send_sns_notification(topic_arn, message_body)

    return {
        'statusCode': 200,
        'body': 'IAM credential report generated and notification sent.'
    }
