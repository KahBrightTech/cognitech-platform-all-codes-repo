import boto3
import os
import json
from datetime import datetime, timezone

def lambda_handler(event, context):
    iam = boto3.client('iam')
    lambda_client = boto3.client('lambda')
    now = datetime.now(timezone.utc)
    users = iam.list_users()['Users']
    report_lines = []

    for user in users:
        username = user['UserName']
        created = user['CreateDate']
        age_days = (now - created).days
        report_lines.append(f"User: {username}, Account Age: {age_days} days")

        access_keys = iam.list_access_keys(UserName=username)['AccessKeyMetadata']
        for key in access_keys:
            key_id = key['AccessKeyId']
            key_created = key['CreateDate']
            key_age = (now - key_created).days
            report_lines.append(f"  AccessKey: {key_id}, Age: {key_age} days")

        try:
            user_info = iam.get_user(UserName=username)['User']
            pwd_last_used = user_info.get('PasswordLastUsed')
            if pwd_last_used:
                pwd_age = (now - pwd_last_used).days
                report_lines.append(f"  Password last used: {pwd_age} days ago")
            else:
                report_lines.append("  Password never used")
        except Exception:
            report_lines.append("  No password info available")

    report = "\n".join(report_lines)

    lambda_client.invoke(
        FunctionName=os.environ['NOTIFY_FUNCTION_NAME'],
        InvocationType='Event',
        Payload=json.dumps({'message': report})
    )

    return {'status': 'Report generated and notification triggered'}
