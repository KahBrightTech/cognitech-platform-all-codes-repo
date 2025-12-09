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

#### Create your first EKS Cluster:
- To create an EKS cluster using eksctl, run the following command:
```
  eksctl create cluster --name=eksdemo1 --region=us-east-1 --zones=us-east-1a,us-east-1b --without-nodegroup
```
- This command creates an EKS cluster named "eksdemo1" in the "us-east-1" region, spanning the specified availability zones, without creating a node group.
- To verify that the cluster has been created, run:
```aws eks --region us-east-1 list-clusters```
- This command lists all the EKS clusters in the specified region.
- If you dont specify the region, it will use the default region set in your AWS CLI configuration.
- This takes about 15-20 minutes to create the cluster.
- This command also creates a VPC with public and private subnets, internet gateway, NAT gateway, and route tables.
- Once the cluster is created, eksctl automatically configures your kubectl context to use the new cluster.
- To check the kubectl context, run:
```kubectl config get-contexts```
- This command lists all the kubectl contexts and highlights the current context.
- The kubernetes context contains information about the cluster, user, and namespace.
- To view the details of the current context, run:
```kubectl config view --minify```  
- To view the clusters created in EKS, run:
```eksctl get cluster```
##### Create the IAM OIDC Provider:
- To enable and use AWS roles for kubernetes service accounts on our EKS cluster we must create and associate OIOC provider with our EKS cluster.
- To create an IAM OIDC provider for our EKS cluster, run the following command:
```eksctl utils associate-iam-oidc-provider --region us-east-1 --cluster eksdemo1 --approve```
- This command associates an IAM OIDC provider with the specified EKS cluster in the given region.
- To verify that the OIDC provider has been created, run:
```aws iam list-open-id-connect-providers```
- This command lists all the IAM OIDC providers in your AWS account.
- **This command is now redundant as eksctl automatically creates the OIDC provider when creating the EKS cluster.** 
#### Create EKS Managed Nodes and IAM OIDC Provider:
##### Create EKS Managed Node Group:
- To create an EKS managed node group, run the following command:
```eksctl create nodegroup --cluster=eksdemo1 --region=us-east-1 --name=eksdemo1-ng-public1 --node-type=t3.medium --nodes=2 --nodes-min=2 --nodes-max=4 --node-volume-size=20 --ssh-access --ssh-public-key=shared-key-pair --managed --asg-access --external-dns-access --full-ecr-access --appmesh-access --alb-ingress-access 
```
- This command creates a managed node group named "eksdemo1-ng-public1" in the "eksdemo1" cluster, with t3.medium instance type, 2 initial nodes, minimum 2 nodes, maximum 4 nodes, 20 GB volume size, SSH access using the specified public key, and various IAM permissions for the node group.
      --asg-access                  enable IAM policy for cluster-autoscaler 
      --external-dns-access         enable IAM policy for external-dns
      --full-ecr-access             enable full access to ECR
      --appmesh-access              enable full access to AppMesh
      --appmesh-preview-access      enable full access to AppMesh Preview
      --alb-ingress-access          enable full access for alb-ingress-controller
      --install-neuron-plugin       install Neuron plugin for Inferentia and Trainium nodes (default true)
      --install-nvidia-plugin       install Nvidia plugin for GPU nodes (default true)
      --nodegroup-parallelism int   Number of self-managed or managed nodegroups to create in parallel (default 8)
- All the above permissions can be seen in the IAM role created for the EC2 instances in the node group.
- These permissions allow the worker nodes to interact with other AWS services as needed.
- These can also be added later to the node group IAM role if needed.
- managed node groups are automatically updated and maintained by AWS, making it easier to manage the worker nodes in your EKS cluster.
- The security group created for the node group allows inbound traffic on port 22 (SSH) from anywhere on ipv4 and ipv6. 
- Its called remote access security group.
- To verify that the node group has been created, run:
```eksctl get nodegroup --cluster=eksdemo1 --region=us-east-1```
- This command lists all the node groups in the specified EKS cluster and region.
- On the console you can find the nodegroup under the EKS cluster compute section
- To view the EC2 instances created for the node group, go to the EC2 console and check for instances with the tag "eks:cluster-name" set to "eksdemo1" and "eks:nodegroup-name" set to "eksdemo1-ng-public1".
- To check the kubernetes nodes, run:
```kubectl get nodes```
#### Delete EKS Cluster and Node Group:
- To delete the EKS managed node group, run the following command:
```eksctl delete nodegroup --cluster=eksdemo1 --region=us-east-1 --name=eksdemo1-ng-public1```
- This command deletes the specified node group from the given EKS cluster and region. This should be done before deleting the cluster.
- To delete the EKS cluster, run the following command:
```eksctl delete cluster --name=eksdemo1 --region=us-east-1```
### Docker Fundamentals for EKS:
- Docker is a platform that allows developers to easily create, deploy, and run applications in containers
### Kubernetes Fundamentals: 
- In eks we have the eks controller manager and fargate controller that manage the worker nodes and fargate profiles respectively.
- The worker nodes still have kubelet, kube-proxy and container runtime installed on them.
- eks lets on focus on deploying and managing applications rather than managing the underlying infrastructure.
#### Imperative vs Declarative:
- Imperative approach involves giving specific commands to achieve a desired state.
- Declarative approach involves defining the desired state of the system and letting the system figure out how to achieve that state.
- Kubernetes uses a declarative approach, where we define the desired state of our applications and the system works to maintain that state.
#### Kubernetes pods: 
- Kubernestes goal is to deploy our applications in the form of containers on worker nodes in a k8s cluster.
- A pod is the smallest deployable unit in kubernetes
- The containers are not deployed directly on the worker nodes, instead they are deployed inside pods.
- A pod can contain one or more containers that share the same network namespace and storage volumes.
- A pod is a single instance of a running process in our cluster.
- Pods are ephemeral, meaning they can be created, destroyed, and recreated as needed.
- Its not good practice to have multiple containers of the same kind in a single pod.
- for instance 2 nginx containers in a single pod is not a good practice.
- Instead create multiple pods with a single nginx container in each pod.
- You can have multiple containers in thesame pod provided they are not of thesame kind and they work together to achieve a common goal.
- For instance helper containers that assist the main container in the pod.
- Helper containers are also known as sidecar containers.
- They are used to pull data required by the main container, perform logging, or handle other auxiliary tasks.
- They also help push data from the main container to external systems.
- They can also server as proxies for the main container.
##### K8s pods demo:























