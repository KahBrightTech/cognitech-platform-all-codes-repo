# Update IAM policy to include GitHub Credentials secret access

$policyJson = @'
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowGetAndPutSecret",
      "Effect": "Allow",
      "Action": [
        "secretsmanager:GetSecretValue",
        "secretsmanager:PutSecretValue",
        "secretsmanager:DescribeSecret"
      ],
      "Resource": [
        "arn:aws:secretsmanager:us-east-1:730335294148:secret:int-preproduction-use1-shared-*",
        "arn:aws:secretsmanager:us-east-1:730335294148:secret:int-preproduction-use1-GitHub-Credentials-*"
      ]
    }
  ]
}
'@

# Save policy to file
$policyJson | Out-File -FilePath "policy-update.json" -Encoding utf8 -NoNewline

Write-Host "Creating new policy version..." -ForegroundColor Yellow

# Create new policy version and set as default
aws iam create-policy-version `
  --policy-arn arn:aws:iam::730335294148:policy/int-preproduction-use1-shared-InfoGrid-sa-policy `
  --policy-document file://policy-update.json `
  --set-as-default

if ($LASTEXITCODE -eq 0) {
    Write-Host "`nPolicy updated successfully!" -ForegroundColor Green
    Write-Host "`nNow delete and recreate the pod:" -ForegroundColor Cyan
    Write-Host "  kubectl delete pod secrets-sync" -ForegroundColor White
    Write-Host "  kubectl apply -f UnderstandingSecrets/03-secret_sync_pod.yaml" -ForegroundColor White
} else {
    Write-Host "`nPolicy update failed!" -ForegroundColor Red
}

# Clean up
Remove-Item "policy-update.json" -ErrorAction SilentlyContinue
