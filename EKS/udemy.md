### AWS EKS - Elastic Kubernetes Service (Udemy Course)
#### Installing the 3 clis needed to work with EKS
1. AWS CLI
    - https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html
    - To install AWS CLI on Windows using Chocolatey, run the following command in an elevated PowerShell or Command Prompt:
      ```
      choco install awscli
      ```
      - To check if AWS CLI is installed correctly, run:
      ```
      aws --version
      ```
2. kubectl
    - https://kubernetes.io/docs/tasks/tools/install-kubectl/
    - To install kubectl on Windows using Chocolatey, run the following command in an elevated PowerShell or Command Prompt:
      ```
      choco install kubernetes-cli
      ```
      - To check if kubectl is installed correctly, run:
      ```
      kubectl version --client
      ```
3. eksctl
    - https://docs.aws.amazon.com/eks/latest/userguide/eksctl.html  
    - To install eksctl on Windows using Chocolatey, run the following command in an elevated PowerShell or Command Prompt:
      ```
      choco install eksctl
      ```
    - To check if eksctl is installed correctly, run:
      ```
      eksctl version
      ```
#### EKS Cluster Introduction:
- EKS is a managed Kubernetes service provided by AWS that simplifies the process of deploying, managing, and scaling containerized applications using Kubernetes.
- Eks Cluster has 4 main components:
  1. Control Plane
  2. Worker Nodes and node groups
  3. Fargat profiles 
  4. VPC
##### EKS Control Plane:
- The control plane is responsible for managing the Kubernetes cluster and consists of components such as the kube-apiserver, etcd (the cluster's data store), kube-scheduler, and kube-controller-manager.
- It runs a single-tenant control plane for each EKS cluster and is not shared with other AWS accounts or across clusters.
- it consist of atleast 2 api server nodes and 3 etcd nodes that are distributed across 3 Availability Zones (AZs) for high availability.
- EKS automatically detects and replaces unhealthy control plane instances restarting them across the azs within the region as needed. 
- Its a managed service by AWS, meaning AWS takes care of the availability and scalability of the control plane.
- In regular kubernetes setup, you would have to manage the control plane yourself.
##### EKS Worker Nodes and Node Groups:
- Worker nodes are the EC2 instances that run your containerized applications. 
- A node group is one or more worker nodes that share the same configuration, such as instance type, AMI, and scaling policies.
- You can create and manage node groups using eksctl or the AWS Management Console.
- The worker nodes run in our AWS account and connect to our **clusters control plane using the cluster API server endpoint**.
- The ec2 instances are deployed  in a autoscaling group across multiple availability zones for high availability.
##### Fargate Profiles:
- Fargate profiles allow you to run Kubernetes pods on AWS Fargate, which is a serverless compute engine for containers.
- Instead of EC2 instances, we run our application workloads on serverless Fargate profiles.
- Fargate is a technology that provides on-demand, right-sized compute capacity for containers without the need to manage the underlying infrastructure.
- With Fargate we no lo nger have to provision, configure, or scale clusters of virtual machines to run containers.
- Each pod running on fargate has its own isolation boundary and does not share the underlying kernel, CPU resources, memory, or elastic network interface with other pods.
- AWS specifically built fargate controllers that recognize the pods belonging to fargate and schedules them on fargate profiles
- **Fargate profiles only run on private subnets within the VPC.**
##### VPC:
- With AWS VPC we follow secure networking standards which will allow us to run production workloads on EKS.
- EKS uses AWS vpc network policies to restrict traffic between control plane and components within a single cluster
- Control plane components for EKS cluster cannot view view or receive communication from another cluster or other AWS accounts, except as authorized with kubernetes role-based access control (RBAC) and IAM policies.
- This secure and highly available configuration makes EKS reliable anbd recommended for production workloads

### How does EKS work?

![EKS Architecture](../Kubernetes/screenshots/pic4.png)
- EKS























