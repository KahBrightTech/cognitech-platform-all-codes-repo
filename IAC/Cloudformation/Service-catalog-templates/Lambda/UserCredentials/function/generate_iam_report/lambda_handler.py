import boto3
import os
import json
from datetime import datetime
from notifier import send_sns_notification

def lambda_handler(event, context):
    iam = boto3.client('iam')

    users = iam.list_users()['Users']
    report = []

    for user in users:
        username = user['UserName']
        access_keys = iam.list_access_keys(UserName=username)['AccessKeyMetadata']
        user_report = {
            "UserName": username,
            "AccessKeys": []
        }

        for key in access_keys:
            key_id = key['AccessKeyId']
            create_date = key['CreateDate']

            # Convert create_date to naive datetime if needed
            if create_date.tzinfo is not None:
                create_date = create_date.replace(tzinfo=None)

            days_since_creation = (datetime.now() - create_date).days

            last_used_info = iam.get_access_key_last_used(AccessKeyId=key_id)
            last_used_date = last_used_info['AccessKeyLastUsed'].get('LastUsedDate', 'Never used')
            region = last_used_info['AccessKeyLastUsed'].get('Region', 'N/A')
            service = last_used_info['AccessKeyLastUsed'].get('ServiceName', 'N/A')

            key_data = {
                "KeyID": key_id,
                "Created": create_date.isoformat(),
                "DaysSinceCreation": days_since_creation,
                "Expired": days_since_creation > 90,
                "LastUsed": str(last_used_date),
                "Region": region,
                "Service": service
            }

            user_report["AccessKeys"].append(key_data)

        report.append(user_report)

    if report:
        message_body = "IAM Credential Report (JSON):\n\n" + json.dumps(report, indent=2, default=str)
    else:
        message_body = "IAM Credential Report: No users or keys found."

    topic_arn = os.environ['SNS_TOPIC_ARN']
    send_sns_notification(topic_arn, message_body)

    return {
        'statusCode': 200,
        'body': 'IAM credential report generated and notification sent.'
    }
