# =============================================================================
# IAM CONFIGURATION FOR AWS SECRETS MANAGER + EKS CSI DRIVER
# =============================================================================

# Step 1: Create IAM Policy for Secrets Manager Access
# Save this as secrets-manager-policy.json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "secretsmanager:GetSecretValue",
        "secretsmanager:DescribeSecret"
      ],
      "Resource": [
        "arn:aws:secretsmanager:us-east-1:123456789012:secret:prod/db/credentials-*",
        "arn:aws:secretsmanager:us-east-1:123456789012:secret:prod/external/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "ssm:GetParameter",
        "ssm:GetParameters"
      ],
      "Resource": [
        "arn:aws:ssm:us-east-1:123456789012:parameter/prod/api/*"
      ]
    }
  ]
}

# Step 2: Create the IAM Policy
aws iam create-policy \
  --policy-name EKS-SecretsManager-Policy \
  --policy-document file://secrets-manager-policy.json

# Step 3: Create IAM Role with Trust Policy for OIDC Provider
# Replace OIDC_PROVIDER with your EKS cluster's OIDC provider URL
# Get it with: aws eks describe-cluster --name my-cluster --query "cluster.identity.oidc.issuer" --output text

cat > trust-policy.json <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::123456789012:oidc-provider/oidc.eks.us-east-1.amazonaws.com/id/EXAMPLED539D4633E53DE1B71EXAMPLE"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "oidc.eks.us-east-1.amazonaws.com/id/EXAMPLED539D4633E53DE1B71EXAMPLE:sub": "system:serviceaccount:default:app-service-account",
          "oidc.eks.us-east-1.amazonaws.com/id/EXAMPLED539D4633E53DE1B71EXAMPLE:aud": "sts.amazonaws.com"
        }
      }
    }
  ]
}
EOF

# Step 4: Create IAM Role
aws iam create-role \
  --role-name eks-secrets-manager-role \
  --assume-role-policy-document file://trust-policy.json

# Step 5: Attach Policy to Role
aws iam attach-role-policy \
  --role-name eks-secrets-manager-role \
  --policy-arn arn:aws:iam::123456789012:policy/EKS-SecretsManager-Policy

# =============================================================================
# AWS SECRETS MANAGER - CREATE SECRET
# =============================================================================

# Method 1: Create secret from JSON string
aws secretsmanager create-secret \
  --name prod/db/credentials \
  --description "Database credentials for production" \
  --secret-string '{
    "username": "dbadmin",
    "password": "SuperSecurePassword123!",
    "host": "prod-db.cluster-xxxxx.us-east-1.rds.amazonaws.com",
    "port": "5432",
    "database": "myapp"
  }' \
  --region us-east-1

# Method 2: Create secret from file
echo '{
  "username": "dbadmin",
  "password": "SuperSecurePassword123!",
  "host": "prod-db.cluster-xxxxx.us-east-1.rds.amazonaws.com",
  "port": "5432",
  "database": "myapp"
}' > db-creds.json

aws secretsmanager create-secret \
  --name prod/db/credentials \
  --secret-string file://db-creds.json \
  --region us-east-1

# Delete the file after creating the secret
rm db-creds.json

# =============================================================================
# ENABLE AUTOMATIC SECRET ROTATION
# =============================================================================

# For RDS databases, enable automatic rotation
aws secretsmanager rotate-secret \
  --secret-id prod/db/credentials \
  --rotation-lambda-arn arn:aws:lambda:us-east-1:123456789012:function:SecretsManagerRotationFunction \
  --rotation-rules AutomaticallyAfterDays=30 \
  --region us-east-1

# =============================================================================
# INSTALL SECRETS STORE CSI DRIVER (If not already installed)
# =============================================================================

# Add Helm repo
helm repo add secrets-store-csi-driver https://kubernetes-sigs.github.io/secrets-store-csi-driver/charts
helm repo update

# Install CSI Driver
helm install csi-secrets-store secrets-store-csi-driver/secrets-store-csi-driver \
  --namespace kube-system \
  --set syncSecret.enabled=true \
  --set enableSecretRotation=true \
  --set rotationPollInterval=3600s

# Install AWS Provider
kubectl apply -f https://raw.githubusercontent.com/aws/secrets-store-csi-driver-provider-aws/main/deployment/aws-provider-installer.yaml

# =============================================================================
# VERIFY SETUP
# =============================================================================

# Check if CSI driver is running
kubectl get pods -n kube-system -l app=secrets-store-csi-driver

# Check if AWS provider is running
kubectl get pods -n kube-system -l app=csi-secrets-store-provider-aws

# Verify service account annotation
kubectl describe serviceaccount app-service-account

# Test secret access (after deploying the pod)
kubectl exec -it <pod-name> -- ls -la /mnt/secrets-store
kubectl exec -it <pod-name> -- cat /mnt/secrets-store/DB_USER
kubectl exec -it <pod-name> -- env | grep DB_

# Check if Kubernetes Secret was created (if using secretObjects)
kubectl get secret db-secret -o yaml

# View pod logs for any CSI driver errors
kubectl logs <pod-name> -c app
kubectl describe pod <pod-name>

# =============================================================================
# SECURITY ENHANCEMENTS
# =============================================================================

# 1. Enable VPC Endpoint for Secrets Manager (avoid internet routing)
aws ec2 create-vpc-endpoint \
  --vpc-id vpc-xxxxx \
  --service-name com.amazonaws.us-east-1.secretsmanager \
  --route-table-ids rtb-xxxxx \
  --subnet-ids subnet-xxxxx subnet-yyyyy

# 2. Enable AWS CloudTrail for audit logging
aws cloudtrail create-trail \
  --name secrets-audit-trail \
  --s3-bucket-name my-cloudtrail-bucket

aws cloudtrail put-event-selectors \
  --trail-name secrets-audit-trail \
  --event-selectors '[{
    "ReadWriteType": "All",
    "IncludeManagementEvents": true,
    "DataResources": [{
      "Type": "AWS::SecretsManager::Secret",
      "Values": ["arn:aws:secretsmanager:us-east-1:123456789012:secret:prod/*"]
    }]
  }]'

# 3. Enable encryption at rest for EKS etcd (if using secretObjects)
# This is done at cluster creation time
aws eks create-cluster \
  --name my-cluster \
  --encryption-config '[{
    "resources": ["secrets"],
    "provider": {
      "keyArn": "arn:aws:kms:us-east-1:123456789012:key/xxxxx"
    }
  }]'

# =============================================================================
# TROUBLESHOOTING
# =============================================================================

# Check CSI driver logs
kubectl logs -n kube-system -l app=secrets-store-csi-driver

# Check AWS provider logs
kubectl logs -n kube-system -l app=csi-secrets-store-provider-aws

# Test IAM permissions from pod
kubectl run -it --rm aws-cli --image=amazon/aws-cli --serviceaccount=app-service-account -- \
  secretsmanager get-secret-value --secret-id prod/db/credentials --region us-east-1

# View IAM role credentials in pod
kubectl exec -it <pod-name> -- env | grep AWS_
