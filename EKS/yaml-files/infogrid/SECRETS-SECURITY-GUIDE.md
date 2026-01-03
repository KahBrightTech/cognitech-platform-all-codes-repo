# AWS Secrets Manager + CSI Driver - Complete Security Guide

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                         AWS Cloud                            │
│  ┌────────────────────┐         ┌─────────────────────┐    │
│  │ AWS Secrets        │         │  IAM Role           │    │
│  │ Manager            │◄────────│  (IRSA)             │    │
│  │                    │         │                     │    │
│  │ - DB Credentials   │         │  Policy: Allow      │    │
│  │ - API Keys         │         │  GetSecretValue     │    │
│  │ - Certificates     │         └─────────┬───────────┘    │
│  └────────────────────┘                   │                │
│           ▲                                │                │
│           │                                │                │
│  ┌────────┴────────────────────────────────┴────────┐      │
│  │              EKS Cluster                         │      │
│  │                                                   │      │
│  │  ┌─────────────────────────────────────────┐    │      │
│  │  │  Namespace: default                     │    │      │
│  │  │                                         │    │      │
│  │  │  ┌────────────────────────────────┐    │    │      │
│  │  │  │ Service Account                │    │    │      │
│  │  │  │ (app-service-account)          │◄───┼────┼──────┘
│  │  │  │                                │    │    │
│  │  │  │ Annotation:                    │    │    │
│  │  │  │ eks.amazonaws.com/role-arn     │    │    │
│  │  │  └────────┬───────────────────────┘    │    │
│  │  │           │                             │    │
│  │  │  ┌────────▼───────────────────────┐    │    │
│  │  │  │ SecretProviderClass            │    │    │
│  │  │  │ (aws-db-secrets)               │    │    │
│  │  │  │                                │    │    │
│  │  │  │ - Defines which secrets        │    │    │
│  │  │  │ - Maps to K8s Secret           │    │    │
│  │  │  │ - JMESPath filtering           │    │    │
│  │  │  └────────┬───────────────────────┘    │    │
│  │  │           │                             │    │
│  │  │  ┌────────▼───────────────────────┐    │    │
│  │  │  │ Pod                            │    │    │
│  │  │  │                                │    │    │
│  │  │  │ ┌──────────────────────────┐  │    │    │
│  │  │  │ │ CSI Volume Mount         │  │    │    │
│  │  │  │ │ /mnt/secrets-store/      │  │    │    │
│  │  │  │ │ - DB_USER                │  │    │    │
│  │  │  │ │ - DB_PASSWORD            │  │    │    │
│  │  │  │ │ - DB_HOST                │  │    │    │
│  │  │  │ └──────────────────────────┘  │    │    │
│  │  │  │                                │    │    │
│  │  │  │ ┌──────────────────────────┐  │    │    │
│  │  │  │ │ Environment Variables    │  │    │    │
│  │  │  │ │ (from K8s Secret)        │  │    │    │
│  │  │  │ │ - DB_USERNAME            │  │    │    │
│  │  │  │ │ - DB_PASSWORD            │  │    │    │
│  │  │  │ └──────────────────────────┘  │    │    │
│  │  │  └────────────────────────────────┘    │    │
│  │  └─────────────────────────────────────────┘    │
│  └───────────────────────────────────────────────────┘
└─────────────────────────────────────────────────────────────┘
```

## Security Features

### 1. **No Secrets in etcd** (File-based)
- Secrets mounted directly as files from CSI driver
- Never stored in Kubernetes etcd
- Retrieved on-demand from AWS Secrets Manager

### 2. **IRSA (IAM Roles for Service Accounts)**
- Pod assumes IAM role automatically
- No long-lived credentials in cluster
- AWS STS provides temporary credentials (15-min tokens)
- Least-privilege IAM policies

### 3. **Encryption**
- **In Transit**: TLS 1.2+ from pod to AWS Secrets Manager
- **At Rest**: AWS KMS encryption in Secrets Manager
- **Optional**: Encrypt K8s etcd if using secretObjects

### 4. **Automatic Rotation**
- Configure rotation schedule (e.g., every 30 days)
- Lambda function updates database and secret atomically
- CSI driver refreshes secrets without pod restart

### 5. **Audit Logging**
- CloudTrail logs all `GetSecretValue` API calls
- Track which pod accessed which secret
- Detect unauthorized access attempts

### 6. **Network Security**
- VPC endpoints for Secrets Manager (no internet traffic)
- Security groups control pod-to-VPC-endpoint access
- PrivateLink ensures traffic stays within AWS network

## Security Best Practices

### ✅ DO's

1. **Use IRSA, not access keys**
   ```yaml
   serviceAccountName: app-service-account  # Links to IAM role
   ```

2. **Apply least-privilege IAM policies**
   - Specify exact secret ARNs (not `*`)
   - Only grant `GetSecretValue`, not `PutSecretValue`

3. **Enable automatic rotation**
   ```bash
   aws secretsmanager rotate-secret --secret-id prod/db/credentials \
     --rotation-rules AutomaticallyAfterDays=30
   ```

4. **Use VPC endpoints**
   - Avoid routing traffic through internet gateway
   - Lower latency, higher security

5. **Enable CloudTrail auditing**
   ```bash
   aws cloudtrail put-event-selectors --trail-name secrets-audit-trail \
     --event-selectors '[{"DataResources": [{"Type": "AWS::SecretsManager::Secret"}]}]'
   ```

6. **Use JMESPath to extract specific fields**
   ```yaml
   jmesPath:
     - path: password
       objectAlias: DB_PASSWORD  # Only extract password, not entire JSON
   ```

7. **Set short refresh intervals**
   ```bash
   helm install csi-secrets-store --set rotationPollInterval=3600s  # 1 hour
   ```

8. **Encrypt etcd if using secretObjects**
   ```bash
   aws eks create-cluster --encryption-config '[{"resources": ["secrets"]}]'
   ```

### ❌ DON'Ts

1. **Never hardcode secrets in YAML**
   ```yaml
   # WRONG!
   env:
     - name: DB_PASSWORD
       value: "mysecretpassword"  # Never do this
   ```

2. **Don't use ConfigMaps for sensitive data**
   - ConfigMaps are not encrypted
   - Use Secrets or CSI driver

3. **Don't grant broad IAM permissions**
   ```json
   // WRONG!
   "Resource": "*"  // Too permissive
   
   // CORRECT
   "Resource": "arn:aws:secretsmanager:us-east-1:123456:secret:prod/db/*"
   ```

4. **Don't store secrets in Git**
   - Never commit AWS credentials
   - Use `.gitignore` for sensitive files

5. **Don't skip rotation**
   - Static credentials increase breach risk
   - Rotate at least every 90 days

## How It Works: Step-by-Step

### 1. **Pod Starts**
```
Pod → Requests volume mount from CSI driver
```

### 2. **CSI Driver Authenticates**
```
CSI Driver → Gets IAM credentials from IRSA (via Service Account)
CSI Driver → Assumes IAM role using OIDC provider
AWS STS → Returns temporary credentials (15 min)
```

### 3. **Fetch Secrets**
```
CSI Driver → Calls AWS Secrets Manager API with IAM credentials
AWS Secrets Manager → Decrypts secret using KMS
AWS Secrets Manager → Returns secret value
```

### 4. **Mount Secrets**
```
CSI Driver → Writes secrets as files to /mnt/secrets-store/
Pod → Reads files or uses env vars from K8s Secret
```

### 5. **Automatic Refresh** (if rotation enabled)
```
Every 1 hour (configurable):
  CSI Driver → Re-fetches secrets from AWS
  CSI Driver → Updates files in /mnt/secrets-store/
  Application → Reads updated values (no restart needed)
```

## Comparison: secretObjects vs File-Only

| Feature | File-Only Mount | With secretObjects |
|---------|----------------|-------------------|
| **Storage** | Files in `/mnt/secrets-store/` | Files + K8s Secret |
| **Environment Variables** | Manual file reading | Native env var support |
| **etcd Storage** | No (most secure) | Yes (encrypted if configured) |
| **Simplicity** | Requires app changes | Works with existing apps |
| **Security** | Best (no etcd) | Good (encrypted etcd) |

## Real-World Example

### Your Current Setup
```yaml
# Your secretproviderclass.yaml
spec:
  provider: aws
  parameters:
    objects: |
      - objectName: "int-preproduction-use1-shared-user-credentials..."
        objectType: "secretsmanager"
```

### Enhanced Secure Setup
```yaml
spec:
  provider: aws
  parameters:
    objects: |
      - objectName: "int-preproduction-use1-shared-user-credentials..."
        objectType: "secretsmanager"
        jmesPath:
          - path: username
            objectAlias: DB_USER
          - path: password
            objectAlias: DB_PASSWORD
  secretObjects:
    - secretName: db-secret
      type: Opaque
      data:
        - objectName: DB_USER
          key: username
        - objectName: DB_PASSWORD
          key: password
```

## Monitoring & Troubleshooting

### Check if secrets are mounted
```bash
kubectl exec -it <pod> -- ls -la /mnt/secrets-store/
```

### View secret values (for testing only!)
```bash
kubectl exec -it <pod> -- cat /mnt/secrets-store/DB_PASSWORD
```

### Check CSI driver logs
```bash
kubectl logs -n kube-system -l app=secrets-store-csi-driver
```

### Test IAM permissions
```bash
kubectl run aws-test --rm -it --image=amazon/aws-cli \
  --serviceaccount=app-service-account -- \
  secretsmanager get-secret-value --secret-id prod/db/credentials
```

### View CloudTrail audit logs
```bash
aws cloudtrail lookup-events \
  --lookup-attributes AttributeKey=ResourceName,AttributeValue=prod/db/credentials
```

## Cost Optimization

1. **Secrets Manager pricing**: $0.40/secret/month + $0.05 per 10,000 API calls
2. **Reduce API calls**: Use longer `rotationPollInterval`
3. **VPC endpoints**: $0.01/hour + data transfer (minimal cost for high security)
4. **CloudTrail**: S3 storage costs for audit logs

## Quick Start Checklist

- [ ] Install Secrets Store CSI Driver
- [ ] Install AWS Secrets Provider
- [ ] Create secret in AWS Secrets Manager
- [ ] Create IAM policy with least-privilege permissions
- [ ] Create IAM role with OIDC trust policy
- [ ] Create Kubernetes ServiceAccount with role annotation
- [ ] Create SecretProviderClass
- [ ] Deploy pod with CSI volume mount
- [ ] Enable automatic rotation
- [ ] Enable CloudTrail auditing
- [ ] Configure VPC endpoints
- [ ] Test secret access from pod

## References

- [AWS Secrets Manager](https://aws.amazon.com/secrets-manager/)
- [Secrets Store CSI Driver](https://secrets-store-csi-driver.sigs.k8s.io/)
- [AWS Secrets Provider](https://github.com/aws/secrets-store-csi-driver-provider-aws)
- [IRSA Documentation](https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html)
