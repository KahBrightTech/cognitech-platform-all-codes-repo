
# Step-by-Step Guide: Deploy 3-Tier Ecommerce App to AWS EKS (with AWS Secrets Manager)


## 1. Prerequisites
- AWS CLI configured
- kubectl installed
- Docker installed
- An AWS EKS cluster created and kubectl context set
- Docker Hub account
- AWS Secrets Manager access


## 2. Store Secrets in AWS Secrets Manager

Create a secret in AWS Secrets Manager (e.g., named `ecommerce-db-creds`) with the following key-value pairs:

```
{
  "DB_USER": "ecomuser",
  "DB_PASS": "ecompass",
  "DB_NAME": "ecomdb",
  "DB_HOST": "ecommerce-db"
}
```

## 3. Build and Push Docker Images

### Web
cd EKS/ecommerce/web

docker build -t njibrigthain100/brigthain:ecomm-web .
docker push njibrigthain100/brigthain:ecomm-web

### App
cd ../app

docker build -t njibrigthain100/brigthain:ecomm-app .
docker push njibrigthain100/brigthain:ecomm-app

### DB
# Uses official postgres image, no need to push custom image


## 4. Install AWS Secrets & Configuration Provider (ASCP) Add-on

Follow the official AWS documentation to install the ASCP add-on in your EKS cluster:
https://secrets-store-csi-driver.sigs.k8s.io/getting-started/installation.html

## 5. Create IAM Policy and Kubernetes Service Account

1. Create an IAM policy that allows access to your secret:
   (Replace <ACCOUNT_ID> and <REGION> as needed)

   ```json
   {
     "Version": "2012-10-17",
     "Statement": [
       {
         "Effect": "Allow",
         "Action": [
           "secretsmanager:GetSecretValue"
         ],
         "Resource": "arn:aws:secretsmanager:<REGION>:<ACCOUNT_ID>:secret:ecommerce-db-creds*"
       }
     ]
   }
   ```


2. Create a Kubernetes service account and associate it with the IAM role using IRSA (IAM Roles for Service Accounts).
  See: https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html

3. Make sure your AWS Secrets Manager secret (e.g., int-preproduction-use1-shared-eks-ecommerce) is created and contains all required key-value pairs (DB_USER, DB_PASS, DB_NAME, DB_HOST) before applying the SecretProviderClass YAML file.

4. Apply the SecretProviderClass manifest to sync your AWS Secrets Manager secret into a Kubernetes Secret:
  ```
  kubectl apply -f k8s/secretproviderclass.yaml
  ```
  This will allow the CSI driver to automatically create and sync the Kubernetes Secret (e.g., ecommerce-db-secrets) from your AWS Secrets Manager secret.

## 6. Update Kubernetes Manifests
- Replace `<DOCKERHUB_USERNAME>` in k8s/web.yaml and k8s/app.yaml with your Docker Hub username.
- Update k8s/app.yaml to use the service account and reference secrets from AWS Secrets Manager (see example in k8s/app.yaml).


kubectl apply -f db-configmap.yaml
kubectl apply -f db.yaml
kubectl apply -f app.yaml
kubectl apply -f web.yaml

## 7. Configure DNS for Your Domain

1. After deploying your Ingress, get the ALB DNS name:
  ```
  kubectl get ingress ecommerce-ingress
  ```
  Look for the ADDRESS field (e.g., abc123.elb.amazonaws.com).

2. In your DNS provider (e.g., Route 53), create a CNAME record:
  - Name: www (or your chosen subdomain)
  - Value: The ALB DNS name (e.g., abc123.elb.amazonaws.com)

3. Save and wait for DNS propagation. Now, your domain (e.g., www.your-domain.com) will route to your EKS app.

## 8. HTTPS on ALB, HTTP to Backend

The Ingress is configured to listen on port 443 (HTTPS) on the ALB and forward traffic to port 80 (HTTP) on your backend service (ecommerce-web). This is handled by the ALB and Ingress configuration:

- The ALB terminates SSL/TLS at the load balancer (using your ACM certificate).
- The ALB then forwards the decrypted HTTP traffic to your Kubernetes service on port 80.

No changes are needed in your backend service for HTTPS; it only needs to serve HTTP.

## 7. Deploy to EKS
cd ../k8s

kubectl apply -f db-configmap.yaml
kubectl apply -f db.yaml
kubectl apply -f app.yaml
kubectl apply -f web.yaml


## 8. Access the Application
- Get the LoadBalancer EXTERNAL-IP:
  kubectl get svc ecommerce-web
- Open the EXTERNAL-IP in your browser to access the ecommerce site.


## 9. Clean Up
kubectl delete -f web.yaml
kubectl delete -f app.yaml
kubectl delete -f db.yaml
kubectl delete -f db-configmap.yaml

---


This guide will deploy a secure 3-tier ecommerce app (web, app, db) on AWS EKS using Docker images from Docker Hub and AWS Secrets Manager for sensitive data. The web UI connects to the app server, which communicates with the database. You can extend the app with more features as needed.