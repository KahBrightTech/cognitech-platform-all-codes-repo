
## To launch stack run the following cli command in the Template folder
```bash 
aws cloudformation create-stack --stack-name iam-credential-report --template-body file://main.yaml --parameters file://parameter.json --capabilities CAPABILITY_NAMED_IAM
```
## To test function run the below cli command 
```bash
aws lambda invoke --function-name UserCredentials-GenerateReportFunction --payload '{}' --cli-binary-format raw-in-base64-out \ output.json
```