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
- The container runtime is found in both the control plane and worker nodes.
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
- when app is growing scale the number of pods rather than increasing the number of containers in a pod.
##### K8s pods demo:
###### Kubeconfig file:
The kubeconfig file is used to configure access to Kubernetes clusters. It contains:
Authentication & Authorization:
Cluster API server endpoints (URLs)
Certificate authority data for secure connections
User credentials (certificates, tokens, or authentication provider configs)
Configuration Details:
Clusters: List of Kubernetes clusters you can connect to (name, server URL, CA cert)
Users: Authentication credentials for different users/service accounts
Contexts: Combinations of cluster + user + namespace that define "where" and "as whom" you're working
Current-context: Which context is active (which cluster you're currently talking to)
What it enables:
Switch between multiple Kubernetes clusters (dev, staging, prod)
Use different credentials for different clusters
Set default namespaces per context
Allow kubectl to know which cluster to send commands to
- Each team member can have their own kubeconfig file with access to specific clusters.
- The kubeconfig file is typically located at ~/.kube/config on Linux and macOS,
- to generate the kubeconfig file for an EKS cluster, you can use the AWS CLI command:
```bash
aws eks update-kubeconfig --region region-code --name cluster-name
```

- Make sure that your kubeconfig file located at `C:\Users\your-username\.kube\config` is configured to use the correct EKS cluster context.
- If not run this command to update it:

```bash
aws eks update-kubeconfig --region us-east-1 --name "eks cluster name"
# Example:
aws eks update-kubeconfig --region us-east-1 --name int-preproduction-use1-shared-eks-cluster-eks-cluster
```

###### Creating a namespace using kubectl:
- Run this command to create a new namespace
```kubectl create namespace hway```
- To verify the namespace has been created, run:
```kubectl get namespaces```

###### Creating a pod using kubectl:

- Run this command to check the nodes
```kubectl get nodes```
- Run this command to create a new pod
```
kubectl run my-first-pod --image njibrigthain100/brigthain:cognilife 
```
- You can use the describe pod command to get detailed information about the pod
```kubectl describe pod my-first-pod```
- This information can be found on the console under the pods section of the EKS cluster. 
- Go to the eks cluster and under resource select  pods and select the namespace in which the pod is created, by default its created in the default namespace.
- To check the logs of the pod, run:
```kubectl logs my-first-pod```
- To delete the pod, run:
```kubectl delete pod my-first-pod```

##### K8s service demo:
- A kubernetes service is an abstraction that defines a logical set of pods and a policy by which to access them.
- We can expose an application running on a set of pods using different types of services.
- The most common types of services are:
  1. ClusterIP: Exposes the service on a cluster-internal IP. This type makes the service only reachable from within the cluster.
  2. NodePort: Exposes the service on each Node's IP at a static port (the NodePort). This type makes the service accessible from outside the cluster using <NodeIP>:<NodePort>. You cannot specify the nodeport when creating the service in an imperative way using kubectl. It will be automatically assigned from a range of ports (default: 30000-32767).
  3. LoadBalancer: Exposes the service externally using a cloud provider's load balancer. This type creates an external load balancer that routes traffic to the service.

###### NodePort Service Demo:
- what are the different ports in kubernetes service?
  1. Target Port: The port on which the application is running inside the pod.
  2. Port: The port on which the service is exposed inside the cluster. The service listens on this port and forwards traffic to the target port of the pods.
  3. NodePort: The port on which the service is exposed on each node in the cluster. Worker nodes listen on this port and forward traffic to the service.
- After creating the pod, run this command to create a NodePort service:
```kubectl expose pod my-first-pod --type=NodePort --name=my-first-service --port=80 --target-port=80
```
- This command creates a NodePort service named "my-first-service" that exposes port 80 and forwards traffic to port 80 of the "my-first-pod" pod.
- To get the details of the service, run:
```kubectl get service my-first-service```
- This command displays the details of the service, including the NodePort assigned to it.
- To access the service from outside the cluster, use the public IP address of any worker node and the NodePort assigned to the service.
- You can find the public IP addresses of the worker nodes in the EC2 console.
- To find out what node the pod is running on, run:
```kubectl get pod my-first-pod -o wide```
- To access the application on a browser get the public ip of the node and the nodeport assigned to the service.
- For example, if the public IP of the node is 54.210.123.45 and the NodePort assigned to the service is 30080, you can access the application using the URL:
```http://54.210.123.45:30080```
- To get the nodeport of the service, run:
```kubectl get service my-first-service -o jsonpath='{.spec.ports[0].nodePort}'```
- Make sure that the node security group allows inbound traffic on the nodeport from your IP address.
- The above information can also be found on the console under the services section of the EKS cluster.
- You are able to access the application on the other node as well since the service is exposed on all nodes in the cluster.
- To view the pod logs , run:
```kubectl logs my-first-pod```
- To view the logs in real-time, run:
```kubectl logs my-first-pod -f```
- To get the yaml configuration of the pod, run:
```kubectl get pod my-first-pod -o yaml```
- This provides the complete configuration of the pod in yaml format.

#### ReplicaSets:
- A ReplicaSet is a Kubernetes resource that ensures a specified number of pod replicas are running at any given time.
- It monitors the pods and automatically creates or deletes pods to maintain the desired number of replicas.
- ReplicaSets are typically used to ensure high availability and scalability of applications running in a Kubernetes cluster.
- ReplicaSets are usually created and managed by Deployments, which provide additional features such as rolling updates and rollbacks.
- **Labels and selectors** are used to identify and manage the pods that belong to a ReplicaSet.
- So a combination of replicasets and services help in load balancing and high availability of applications in a kubernetes cluster.
- The service distributes traffic across the multiple pod replicas managed by the ReplicaSet.
##### ReplicaSet Demo:
- To create a ReplicaSet, we first need to create a yaml file that defines the Replica
- Set configuration. Here is an example of a ReplicaSet yaml file named `my-replicaset.yaml`:
```apiVersion: apps/v1
kind: ReplicaSet
metadata:
  name: my-replicaset
spec:
  replicas: 3
  selector:
    matchLabels:
      app: my-app
  template:
    metadata:
      labels:
        app: my-app
    spec:
      containers:
      - name: my-app
        image: my-app-image
        ports:
        - containerPort: 80
````
- To expose the replicaset as a service we can either run the cli command shown below or create a service yaml file.
```kubectl expose rs my-replicaset --type=NodePort --name=my-replicaset-service --port=80 --target-port=80```
- To expose it using the yaml file create a file named `my-replicaset-service.yaml` with the following content:
```apiVersion: v1
kind: Service
metadata:
  name: my-replicaset-service
spec:
  type: NodePort
  selector:
    app: my-app
  ports:
  - protocol: TCP
    port: 80
    targetPort: 80
```
- This exposes the ReplicaSet as a NodePort service named "my-replicaset-service" that listens on port 80 and forwards traffic to port 80 of the pods managed by the ReplicaSet.
- In this case the request gets distributed across the 3 pod replicas created by the ReplicaSet.
- To verify if the replicaset maintains the pods as expected, we can delete one of the pods and check if the replicaset creates a new pod to maintain the desired number of replicas.
- First get the list of pods created by the replicaset using the command:
```kubectl get pods -o wide```
- This command lists all the pods 
- To delete one of the pods, run:
```kubectl delete pod <pod-name>```
- Replace `<pod-name>` with the name of the pod you want to delete.
- After deleting the pod, run the command again to get the list of pods:
```kubectl get pods -o wide```
- You should see that a new pod has been created by the ReplicaSet to maintain the desired number of replicas.
- We can scale our replica set by changing the replicas count in the yaml file and applying the changes using the command:
```kubectl apply -f my-replicaset.yaml```
- **Important concept**: services dont target replicasets by names but rather pods by using labels and selectors.

#### Deployments:
- A Deployment is a higher-level Kubernetes resource that manages ReplicaSets and provides declarative updates to applications.
- Deployments allow you to define the desired state of your application, including the number of replicas, the container image to use, and other configuration details.
- When you create a Deployment, Kubernetes automatically creates a ReplicaSet to manage the pods for that Deployment.
- Deployments provide features such as rolling updates, rollbacks, and scaling, making it easier to manage applications in a Kubernetes cluster.
- You can also pause and resume deployments, allowing you to control the rollout of updates to your application.
- **Clean up policy** is another important feature of deployments that helps manage the lifecycle of ReplicaSets and pods. This policy determines how many old ReplicaSets and pods are retained when a new deployment is made.
- By default, Kubernetes retains all old ReplicaSets and pods, which can lead to resource consumption and clutter in the cluster.
- However, you can configure the clean up policy to limit the number of old ReplicaSets and pods that are retained.
- This helps free up resources and keeps the cluster clean and organized.
- **Canary deployments** are a deployment strategy that allows you to release new versions of your application to a small subset of users before rolling it out to the entire user base.
- This approach helps minimize the impact of potential issues with the new version by limiting exposure.
- In Kubernetes, canary deployments can be implemented using Deployments and Services.
##### Deployment Demo:
- To create a deployment via the cli you can run the command:
```kubectl create deployment my-deployment --image=njibrigthain100/brigthain:hwv1```
- This command creates a deployment named "my-deployment" using the specified container image.
- To expose the deployment as a service, run:
```kubectl expose deployment my-deployment --type=NodePort --name=my-deployment-service --port=80 --target-port=80```
- This command creates a NodePort service named "my-deployment-service" that exposes port 80 and forwards traffic to port 80 of the pods managed by the deployment.
- To verify the deployment and service, run:
```kubectl get deployments```
```kubectl get services```
- To scale the deployment, run:
```kubectl scale deployment my-deployment --replicas=4```
- This command scales the deployment to 4 replicas.
- To update the deployment with a new container image, first find the container name:
```kubectl get deployment dashboard -o jsonpath='{.spec.template.spec.containers[*].name}'```
- Then update the image using the correct container name:
```kubectl set image deployment/my-deployment brigthain=njibrigthain100/brigthain:hwv2 --record=true```
- This command updates the container image of the deployment to the specified new image.
- Kubernetes will automatically create a new ReplicaSet with the updated image and gradually replace the old pods
- To roll back the deployment to the previous version, run:
```kubectl rollout undo deployment/my-deployment```
- This command rolls back the deployment to the previous version.
- To check the rollout status of the deployment, run:
- ```kubectl rollout status deployment/my-deployment```
- To roll back to the second last version, run:
```kubectl rollout undo deployment/my-deployment --to-revision=2```
- To view the revision history of the deployment, run:
```kubectl rollout history deployment/my-deployment```
- This command displays the revision history of the deployment, including the revision numbers and the corresponding container images.
- To create the deployment with a yaml file create a file named `my-deployment.yaml` with the following content:
```apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-deployment
spec:
  replicas: 3
  selector:
    matchLabels:
      app: my-app
  template:
    metadata:
      labels:
        app: my-app
    spec:
      containers:
      - name: my-app
        image: my-app-image
        ports:
        - containerPort: 80
```
- To create the deployment using the yaml file, run:
```kubectl apply -f my-deployment.yaml```
- Kubernetetes deployment typically use rolling update strategy by default to update the application with zero downtime.
- In a rolling update, the deployment gradually replaces old pods with new pods, ensuring that at least a minimum number of pods are always available to serve traffic.
- This approach allows for a smooth transition between application versions without disrupting service availability.- You can customize the rolling update strategy by specifying parameters such as `maxUnavailable` and `maxSurge` in the deployment yaml file.
- `maxUnavailable` specifies the maximum number of pods that can be unavailable during the update process, while `maxSurge` specifies the maximum number of additional pods that can be created during the update process.
- By adjusting these parameters, you can control the speed and impact of the rolling update on your application.
- During an update a new replicaset is created with the new pod template and the old replicaset is scaled down gradually until all the pods are replaced with the new ones.

##### Deployment Edit using kubectl:
- This is the method mostly used to update our applications in kubernetes. 
- To edit your deployment run the command:
```kubectl edit deployment my-deployment --record=true```
- This opens the deployment configuration in the default text editor.
- Make the necessary changes to the deployment configuration, such as updating the container image or changing the number of replicas.
- Save and close the editor to apply the changes.

##### Deployment Rollback application to a previous version:
- To roll back the deployment to the previous version, run:
```kubectl rollout undo deployment/my-deployment```
- This command rolls back the deployment to the previous version.
- To check the rollout status of the deployment, run:
- ```kubectl rollout status deployment/my-deployment```
- To roll back to the second last version, run:
```kubectl rollout undo deployment/my-deployment --to-revision=2```
- To rollback to a specific revision, run:
```kubectl rollout undo deployment/my-deployment --to-revision=<revision-number>```
- To view the revision history of the deployment, run:
```kubectl rollout history deployment/my-deployment```
- To view exaclty what changed in a specific revision, run:
```kubectl rollout history deployment/my-deployment --revision=<revision-number>```
- Now to rollback to previous version you can simp-ly run the undo command without specifying the revision number.
- Everytime you make a change to the deployment using the edit command a new revision is created.
- The revision number is incremented automatically by kubernetes.
- You can also restart the deployment to recreate all the pods without changing the deployment configuration by running:
```kubectl rollout restart deployment/my-deployment```

##### Deployment pausing and resuming deployments:
- To pause a deployment, run:
```kubectl rollout pause deployment/my-deployment```
- To resume a paused deployment, run:
```kubectl rollout resume deployment/my-deployment```
- This is needed when you want to make **multiple changes** to the deployment configuration without triggering a rollout for each change.
- You can pause the deployment, make all the necessary changes, and then resume the deployment to apply all the changes at once.
- Everyytime you create a new deployment a new replicaset is created to manage the pods for that deployment.
- The old replicaset is retained by default unless you specify a clean up policy to limit the number of old replicasets to retain.

#### Services:
- A Kubernetes Service is an abstraction that defines a logical set of pods and a policy by which to access them.
- Services enable communication between different components of an application running in a Kubernetes cluster.
- Services provide a stable IP address and DNS name for a set of pods, allowing other components to access them without needing to know the specific pod IP addresses.
- Services can be exposed in different ways, such as ClusterIP, NodePort, LoadBalancer, and ExternalName, depending on the use case and requirements.
**ClusterIP**: The default type of service that exposes the service on a cluster-internal IP. This type makes the service only reachable from within the cluster. This can be used for internal communication between different components of an application. Or for communication between frontend and backend services within the cluster.
**NodePort**: Exposes the service on each Node's IP at a static port (the NodePort). This type makes the service accessible from outside the cluster using <NodeIP>:<NodePort>. This can be used for development and testing purposes, where you want to access the service from outside the cluster without setting up a load balancer.
**LoadBalancer**: Exposes the service externally using a cloud provider's load balancer. This type creates an external load balancer that routes traffic to the service. This can be used for production workloads where you want to expose the service to the internet and distribute traffic across multiple pods for high availability and scalability.
**ingress**: Ingress is not a type of service but rather a separate Kubernetes resource that manages external access to services in a cluster, typically HTTP/HTTPS traffic. Ingress can provide load balancing, SSL termination, and name-based virtual hosting. Ingress controllers are used to implement the ingress resource and route traffic to the appropriate services based on defined rules. Its advanced load balancing which provides context path based routing, SSL, SSL redirects and many more features.
**ExternalName**: Maps a service to a DNS name outside the cluster. This type can be used to access external services from within the cluster using a consistent DNS name. These are used to access externally hosted apps in kubernetes cluster. For instance AWS RDS database endpoint is to be accessed by an application running in the kubernetes cluster. We can create an externalname service that maps to the RDS endpoint and the application can use the service name to access the database.
![pic3](screenshots/pic1.png)

##### Services demo:
- Go to the github reo and proceed to 05- Services with kubectl 
## Step-01: Introduction to Services
- **Service Types**
  1. ClusterIp
  2. NodePort
  3. LoadBalancer
  4. ExternalName
- We are going to look in to ClusterIP and NodePort in this section with a detailed example. 
- LoadBalancer Type is primarily for cloud providers and it will differ cloud to cloud, so we will do it accordingly (per cloud basis)
- ExternalName doesn't have Imperative commands and we need to write YAML definition for the same, so we will look in to it as and when it is required in our course. 

## Step-02: ClusterIP Service - Backend Application Setup
- Create a deployment for Backend Application (Spring Boot REST Application)
- Create a ClusterIP service for load balancing backend application. 
```
# Create Deployment for Backend Rest App
kubectl create deployment my-backend-rest-app --image=stacksimplify/kube-helloworld:1.0.0 
kubectl get deploy

# Create ClusterIp Service for Backend Rest App
kubectl expose deployment my-backend-rest-app --port=8080 --target-port=8080 --name=my-backend-service
kubectl get svc
Observation: We don't need to specify "--type=ClusterIp" because default setting is to create ClusterIp Service. 
```
- **Important Note:** If backend application port (Container Port: 8080) and Service Port (8080) are same we don't need to use **--target-port=8080** but for avoiding the confusion i have added it. Same case applies to frontend application and service. 

- **Backend HelloWorld Application Source** [kube-helloworld](../00-Docker-Images/02-kube-backend-helloworld-springboot/kube-helloworld)

## Step-03: NodePort Service - Frontend Application Setup
- We have implemented **NodePort Service** multiple times so far (in pods, replicasets and deployments), even then we are going to implement one more time to get a full architectural view in relation with ClusterIp service. 
- Create a deployment for Frontend Application (Nginx acting as Reverse Proxy)
- Create a NodePort service for load balancing frontend application. 
- **Important Note:** In Nginx reverse proxy, ensure backend service name `my-backend-service` is updated when you are building the frontend container. We already built it and put ready for this demo (stacksimplify/kube-frontend-nginx:1.0.0)
- **Nginx Conf File**
```conf
server {
    listen       80;
    server_name  localhost;
    location / {
    # Update your backend application Kubernetes Cluster-IP Service name  and port below      
    # proxy_pass http://<Backend-ClusterIp-Service-Name>:<Port>;      
    proxy_pass http://my-backend-service:8080;
    }
    error_page   500 502 503 504  /50x.html;
    location = /50x.html {
        root   /usr/share/nginx/html;
    }
}
```
- **Docker Image Location:** https://hub.docker.com/repository/docker/stacksimplify/kube-frontend-nginx
- **Frontend Nginx Reverse Proxy Application Source** [kube-frontend-nginx](../00-Docker-Images/03-kube-frontend-nginx)
```
# Create Deployment for Frontend Nginx Proxy
kubectl create deployment my-frontend-nginx-app --image=stacksimplify/kube-frontend-nginx:1.0.0 
kubectl get deploy

# Create ClusterIp Service for Frontend Nginx Proxy
kubectl expose deployment my-frontend-nginx-app  --type=NodePort --port=80 --target-port=80 --name=my-frontend-service
kubectl get svc

# Capture IP and Port to Access Application
kubectl get svc
kubectl get nodes -o wide
http://<node1-public-ip>:<Node-Port>/hello

# Scale backend with 10 replicas
kubectl scale --replicas=10 deployment/my-backend-rest-app

# Test again to view the backend service Load Balancing
http://<node1-public-ip>:<Node-Port>/hello
```rld Application Source** [kube-helloworld](../00-Docker-Images/02-kube-backend-helloworld-springboot/kube-helloworld)

#### Kubernetes declarative approach using YAML files:
- Instead of using the imperative commands to create kubernetes resources we can also use the declarative approach using yaml files.
- The yaml files can be created manually or generated using the kubectl command.
- To generate the yaml file for a deployment, run:
```kubectl get deployment my-deployment -o yaml > my-deployment.yaml```
- This command retrieves the configuration of the specified deployment and saves it to a yaml file named `my-deployment.yaml`.
- You can then edit the yaml file to make any necessary changes to the deployment configuration.
- To apply the changes and create or update the deployment, run:
```kubectl apply -f my-deployment.yaml```
- This command creates or updates the deployment based on the configuration defined in the yaml file.
- This documentation explains how to create a simple pod using a yaml file.
- https://kubernetes.io/docs/concepts/workloads/pods/
- The top level objects in kubernetes are apiversion, kind, metadata and spec.
- apiversion: specifies the version of the kubernetes api being used to create the object.
- kind: specifies the type of object being created (pod, deployment, service, etc). 
- metadata: contains information about the object such as name, namespace, labels, and annotations.
- spec: defines the desired state of the object, including configuration details such as container images, ports, volumes, and resource requirements.
- In the metadata section the name and the labels are the most important fields.
- The name is used to uniquely identify the object within the namespace.
- Labels are key-value pairs that are used to organize and select objects in kubernetes.
- The namespace is used to group related objects together and provide a scope for names. This is also set in the metadata section.
- The spec section contains the configuration details of the object.
- After writing the yaml file we can create the object using the command:
```kubectl apply -f pod.yaml```
- You can also delete resources using the yaml file with the command:
```kubectl delete -f pod.yaml```
- You can also create all resource within a directory using the command:
```kubectl apply -f ./directory-name/```
- This command creates all the resources defined in the yaml files within the specified directory.
- You can also delete all resources within a directory using the command:
```kubectl delete -f ./directory-name/```

#### EKS Secret store CSI Driver:
##### Why was this created:
 - The eks secret yaml is not as secured cause the secret is stored in base64 encoded format which can be easily decoded.
 - To enhance the security of secrets in EKS clusters, AWS created the EKS Secret Store CSI Driver.
 - This driver allows you to securely mount secrets from AWS Secrets Manager or AWS Systems Manager Parameter Store into your Kubernetes pods as files.
 - This eliminates the need to store secrets in plain text or base64 encoded format in Kubernetes manifests
 - The secret store csi driver synchronizes secrets from enxternal APIs and mounts them into containers as volumes. 
 - This allows you to manage secrets in a central place like aws secrets manager and use them securely in your EKS workloads.
 - Here you dont create a kubernetes secret object, instead you create a secret in aws secrets manager and reference it in your pod spec.
 - This minimizes the risk of secret exposure and simplifies secret management in EKS clusters.
 - We use a custom resource definition called SecretProviderClass to define how secrets should be fetched and mounted into pods.
 - Next you create a pod and tell it to use the secret provider class to mount the secrets into the pod.
 - See above for secretproviderclass.yaml and pod_with_secretsprovider.yaml files for reference.
 - Kublet talks to the secrets store csi driver running as a daemonset on each node to fetch and mount the secrets into the pod.
 - The secret provider then fetches the secrets from aws secrets manager and provides them to the csi driver to mount into the pod.
 ##### Hands on demo:
 - First create a secret in aws secrets manager with the name `my-db-credentials` and the following key-value pairs:
   - username: admin
   - password: Password123!
- install the secrets store csi driver using either helm or kubectl.
- To install secrets store csi driver using helm run the following commands:
```helm repo add secrets-store-csi-driver https://kubernetes-sigs.github.io/secrets-store-csi-driver/charts
- Create the secretproviderclass.yaml file as shown above.
- The secrets store csi can also be added as an addon while creating the eks cluster using eksctl.
- Run this command to create the service account for the secrets store csi driver with the necessary iam permissions:
```eksctl create iamserviceaccount --name ecomm-svc --namespace default --cluster int-preproduction-use1-shared-InfoGrid-eks-cluster --role-name sa-role --attach-policy-arn arn:aws:iam::730335294148:policy/eks-test-policy-for-secrets-manager --approve
```
- This command creates an iam service account named `ecomm-svc` in the default namespace of the specified eks cluster.
- The service account is associated with an iam role named `sa-role` that has the specified policy attached to it.
- This policy allows the service account to access secrets from aws secrets manager.
- The service account is then referenced in the pod spec to allow the pod to access the secrets from aws secrets manager.
- Create the pod_with_secretsprovider.yaml file as shown above.

#### Hoe EKS pods access AWS Services:
- How do EKS pods access AWS services securely without using long lived AWS access keys and secret keys?
- For instance how do the pods access S3 buckets, dynamodb tables, sns topics, sqs queues and other aws services securely?
- There is a concept in AWS called PIA - Pod Identity Agent.
- The PIA is a daemonset that runs on each worker node in the eks cluster.
- The PIA is responsible for managing the iam roles associated with the pods running on the nodes.
- The PIA uses the aws sts assume role api to assume the iam role associated with the pod.
- First you need to create an aws iam role.
- So we will create a pod and try to access an S3 bucket.
- The PIA is available as an addon on the eks cluster
- So to set it up we first create an iam role with the necessary permissions to access the aws resource we want the pod to access.
- Next we credate a service account within the required namespace and associate the iam role with the service account using the pod identity assoictaion
- Use the pods_with_pia.yaml file for testing as it has the aws cli installed. 
- Once you have the pod created run the following command to test if it has access to the s3 bucket:
```kubectl exec -it pod-name -- aws s3 ls s3://your-bucket-name
```
- for example to access a specific bucket run:
```kubectl exec -it hway -- aws s3 ls s3://int-preproduction-use1-shared-config-bucket
```
What is a Kubernetes Service Account?
A Service Account is a native Kubernetes resource that provides an identity for pods. By itself, it:

✅ Exists only in Kubernetes
✅ Provides a pod identity within the cluster
✅ Can be used for Kubernetes RBAC
❌ Has NO AWS permissions by default
❌ Cannot access AWS services (S3, DynamoDB, etc.)

yaml# Just a basic Kubernetes Service Account
apiVersion: v1
kind: ServiceAccount
metadata:
  name: my-app-sa
  namespace: default
# This pod can run but CANNOT access AWS services
```

## What is EKS Pod Identity (PIA)?

**EKS Pod Identity** is an AWS feature that **links** a Kubernetes Service Account to an AWS IAM Role, giving pods AWS permissions.
```
┌─────────────────────────┐
│ Kubernetes Service      │
│ Account                 │  ←─── Pod uses this
│ (my-app-sa)            │
└──────────┬──────────────┘
           │
           │ Pod Identity Association
           │ (created by AWS)
           │
           ▼
┌─────────────────────────┐
│ AWS IAM Role            │
│ (with S3, DDB policies) │  ←─── Has AWS permissions
└─────────────────────────┘
The 3 Scenarios
Scenario 1: Service Account ONLY (No AWS Access)
yamlapiVersion: v1
kind: ServiceAccount
metadata:
  name: basic-sa
---
apiVersion: v1
kind: Pod
metadata:
  name: app
spec:
  serviceAccountName: basic-sa
  containers:
  - name: app
    image: myapp:latest
Result:

✅ Pod has Kubernetes identity
❌ Pod CANNOT access AWS services
❌ aws s3 ls will fail with "Unable to locate credentials"

Scenario 2: Service Account + IRSA (Old Way)
IRSA = IAM Roles for Service Accounts (the old method)
hcl# Terraform
resource "kubernetes_service_account" "app" {
  metadata {
    name      = "app-sa"
    namespace = "default"
    annotations = {
      "eks.amazonaws.com/role-arn" = "arn:aws:iam::123456789012:role/app-role"
    }
  }
}
Result:

✅ Pod can access AWS services
⚠️ Requires OIDC provider setup
⚠️ More complex IAM trust policy
⚠️ Annotation required on Service Account

Scenario 3: Service Account + Pod Identity (New Way - Recommended)
hcl# 1. Create Service Account (NO annotations needed)
resource "kubernetes_service_account" "app" {
  metadata {
    name      = "app-sa"
    namespace = "default"
    # Notice: NO annotations!
  }
}

# 2. Create Pod Identity Association (links SA to IAM role)
resource "aws_eks_pod_identity_association" "app" {
  cluster_name    = "my-cluster"
  namespace       = "default"
  service_account = "app-sa"
  role_arn        = aws_iam_role.pod_role.arn
}

# 3. IAM Role with simple trust policy
resource "aws_iam_role" "pod_role" {
  name = "app-pod-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "pods.eks.amazonaws.com"  # Simple!
      }
      Action = ["sts:AssumeRole", "sts:TagSession"]
    }]
  })
}
```

**Result:**
- ✅ Pod can access AWS services
- ✅ Simpler setup (no OIDC needed)
- ✅ No annotations on Service Account
- ✅ Easier to manage

## Visual Comparison
```
┌─────────────────────────────────────────────────────────────┐
│                    SERVICE ACCOUNT ONLY                     │
├─────────────────────────────────────────────────────────────┤
│ Kubernetes Service Account                                  │
│         ↓                                                    │
│       Pod                                                    │
│         ↓                                                    │
│   ❌ No AWS Access                                          │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│              SERVICE ACCOUNT + IRSA (Old Way)               │
├─────────────────────────────────────────────────────────────┤
│ Kubernetes Service Account                                  │
│  (with annotation: eks.amazonaws.com/role-arn)              │
│         ↓                                                    │
│       Pod                                                    │
│         ↓                                                    │
│   OIDC Provider → IAM Role                                  │
│         ↓                                                    │
│   ✅ AWS Access (S3, DynamoDB, etc.)                        │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│          SERVICE ACCOUNT + POD IDENTITY (New Way)           │
├─────────────────────────────────────────────────────────────┤
│ Kubernetes Service Account (plain, no annotations)          │
│         ↓                                                    │
│   Pod Identity Association (AWS resource)                   │
│         ↓                                                    │
│       Pod                                                    │
│         ↓                                                    │
│   IAM Role (simpler trust policy)                           │
│         ↓                                                    │
│   ✅ AWS Access (S3, DynamoDB, etc.)                        │
└─────────────────────────────────────────────────────────────┘
Key Differences Table
FeatureService Account OnlyIRSAPod Identity (PIA)AWS Access❌ No✅ Yes✅ YesAnnotations Required❌ No✅ Yes❌ NoOIDC ProviderN/A✅ Required❌ Not neededSetup ComplexitySimpleComplexSimpleTrust PolicyN/AComplex (OIDC)SimpleRecommendedFor K8s-only appsLegacy✅ Current best practice
IAM Trust Policy Comparison
IRSA Trust Policy (Complex)
json{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Principal": {
      "Federated": "arn:aws:iam::123456789012:oidc-provider/oidc.eks.us-west-2.amazonaws.com/id/EXAMPLED539D4633E53DE1B71EXAMPLE"
    },
    "Action": "sts:AssumeRoleWithWebIdentity",
    "Condition": {
      "StringEquals": {
        "oidc.eks.us-west-2.amazonaws.com/id/EXAMPLED539D4633E53DE1B71EXAMPLE:sub": "system:serviceaccount:default:app-sa",
        "oidc.eks.us-west-2.amazonaws.com/id/EXAMPLED539D4633E53DE1B71EXAMPLE:aud": "sts.amazonaws.com"
      }
    }
  }]
}
Pod Identity Trust Policy (Simple)
json{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Principal": {
      "Service": "pods.eks.amazonaws.com"
    },
    "Action": [
      "sts:AssumeRole",
      "sts:TagSession"
    ]
  }]
}
- To view the IAM role associated to the service account on the console go to the access section on your eks cluster and proceed to the pod identity associations. 
- Here you will see the list of service accounts and their associated iam roles.

#### EKS Storage:
- There are several types of EKS storages available:
1. **EBS (Elastic Block Store) CSI Driver**: EBS is a block storage service that provides persistent storage for EKS pods. EBS volumes can be attached to individual pods and provide high-performance storage for applications that require low-latency access to data. EBS Volumes that are attached to an instance are exposed as storage volumes that persist independently from the life of the instance. The volume can be dynamically changed in size, and can be attached to any instance in the same availability zone. AWS recommends EBS for data that must be accessed quickly and requires long term persistence, such as databases, file systems, and applications that require high IOPS.
2. **EFS (Elastic File System) CSI Driver**: EFS is a file storage service that provides shared storage for EKS pods. EFS volumes can be mounted to multiple pods simultaneously, allowing for easy sharing of data between pods.
3. **FSx for Lustre CSI Driver**: FSx for Lustre is a high-performance file system that can be used to provide fast storage for EKS pods. FSx for Lustre is designed for applications that require high throughput and low latency access to data, such as machine learning and high-performance computing workloads.
- The drivers are not supported on AWS Fargate yet.

##### EKS EBS CSI Driver Demo:
- When installing the ebs csi driver on the console you are asked to do thge installation via pod identity or iam role for service account (IRSA).
- Choose the pod identity method as it is the latest and recommended way.
- When you complete this aws automatically creates a pod identity association for the ebs csi driver service account with the necessary iam role.
- It creates a service account named `ebs-csi-controller-sa` in the `kube-system` namespace and associates it with an iam role that has the necessary permissions to manage ebs volumes.
- In terraform you will have to do the pod identity association manually as shown below:
```hclresource "aws_eks_pod_identity_association" "ebs_csi" {
  cluster_name    = var.cluster_name
  namespace       = "kube-system"
  service_account = "ebs-csi-controller-sa"
  role_arn        = aws_iam_role.ebs_csi_role.arn
}
```
- This is after the addon is installed on the eks cluster.
- Notes from udemy class: 
##### EKS Storage -  Storage Classes, Persistent Volume Claims

**A StorageClass** in EKS (and Kubernetes in general) is a way to define different types of storage that can be dynamically provisioned for your applications.
Think of it as a "storage template" that describes what kind of disk/volume you want and how it should be created.
Why Do We Need StorageClasses?
Without StorageClasses, you'd have to manually create EBS volumes in AWS, then manually attach them to your pods. StorageClasses automate this process - when a pod requests storage, Kubernetes automatically creates the volume for you.
How It Works
Pod needs storage → PersistentVolumeClaim (PVC) → StorageClass → Creates AWS EBS Volume → Mounts to Pod
Example: StorageClass for EBS
yamlapiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: fast-ssd
provisioner: ebs.csi.aws.com  # Uses the EBS CSI driver
parameters:
  type: gp3                    # EBS volume type (gp3, gp2, io1, io2, st1, sc1)
  iops: "3000"                 # IOPS for the volume
  throughput: "125"            # Throughput in MB/s
  encrypted: "true"            # Encrypt the volume
  kmsKeyId: "arn:aws:kms:..."  # Optional: Use specific KMS key
volumeBindingMode: WaitForFirstConsumer  # Wait until pod is scheduled
allowVolumeExpansion: true     # Allow resizing
reclaimPolicy: Delete          # Delete volume when PVC is deleted

**A PersistentVolumeClaim (PVC)** is a request for storage by a user/pod. Think of it like placing an order for disk space.
Simple Analogy
StorageClass = Menu at a restaurant (lists what types of storage are available)
PersistentVolumeClaim (PVC) = Your order from the menu ("I want 10GB of fast SSD storage")
PersistentVolume (PV) = The actual dish that arrives (the actual EBS volume created)
Pod = You eating the food (using the storage)

What Does a PVC Do?
A PVC says: "I need X amount of storage with Y characteristics"
Kubernetes then finds or creates storage that matches your request.
Example PVC
yamlapiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: my-database-storage
  namespace: default
spec:
  accessModes:
    - ReadWriteOnce        # Only one pod can write at a time
  storageClassName: gp3    # Use the gp3 StorageClass
  resources:
    requests:
      storage: 20Gi        # I want 20 gigabytes
**A ConfigMap** is a Kubernetes object that stores configuration data (non-sensitive) as key-value pairs. It lets you separate configuration from your application code.
Simple Analogy
Think of a ConfigMap as a settings file or environment variables file that you can share across multiple pods without hardcoding values into your container images.
Why Use ConfigMaps?
Without ConfigMap ❌
yaml# Hardcoded in your pod
containers:
- name: app
  image: myapp:1.0
  env:
  - name: DATABASE_URL
    value: "postgres://db.example.com:5432"  # Hardcoded!
  - name: LOG_LEVEL
    value: "debug"  # Hardcoded!
With ConfigMap ✅
yaml# Stored separately, reusable, easy to update
containers:
- name: app
  image: myapp:1.0
  envFrom:
  - configMapRef:
      name: app-config  # Reference the ConfigMap
Creating a ConfigMap
Method 1: From Literal Values (Command Line)
bashkubectl create configmap app-config \
  --from-literal=DATABASE_URL=postgres://db.example.com:5432 \
  --from-literal=LOG_LEVEL=debug \
  --from-literal=MAX_CONNECTIONS=100
Method 2: From a File
bash# Create a config file
cat > app.properties << EOF
DATABASE_URL=postgres://db.example.com:5432
LOG_LEVEL=debug
MAX_CONNECTIONS=100
EOF

# Create ConfigMap from file
kubectl create configmap app-config --from-file=app.properties
Method 3: Using YAML (Most Common)
yamlapiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
  namespace: default
data:
  DATABASE_URL: "postgres://db.example.com:5432"
  LOG_LEVEL: "debug"
  MAX_CONNECTIONS: "100"
  # You can also store entire files
  nginx.conf: |
    server {
      listen 80;
      server_name example.com;
      location / {
        proxy_pass http://backend:8080;
      }
    }
Using ConfigMaps in Pods
Option 1: As Environment Variables
yamlapiVersion: v1
kind: Pod
metadata:
  name: myapp
spec:
  containers:
  - name: app
    image: myapp:1.0
    env:
    # Single variable from ConfigMap
    - name: DATABASE_URL
      valueFrom:
        configMapKeyRef:
          name: app-config
          key: DATABASE_URL
    # Another variable
    - name: LOG_LEVEL
      valueFrom:
        configMapKeyRef:
          name: app-config
          key: LOG_LEVEL
Option 2: Load All Keys as Environment Variables
yamlapiVersion: v1
kind: Pod
metadata:
  name: myapp
spec:
  containers:
  - name: app
    image: myapp:1.0
    envFrom:
    - configMapRef:
        name: app-config  # All keys become env vars
Option 3: Mount as Files (Volume)
yamlapiVersion: v1
kind: Pod
metadata:
  name: nginx
spec:
  containers:
  - name: nginx
    image: nginx
    volumeMounts:
    - name: config-volume
      mountPath: /etc/nginx/conf.d  # Mount location
  volumes:
  - name: config-volume
    configMap:
      name: app-config
      items:
      - key: nginx.conf        # Key from ConfigMap
        path: default.conf     # Filename in the pod
```

Inside the pod, you'll have:
```
/etc/nginx/conf.d/default.conf  (contains the nginx.conf content)
Real-World Example: Application Configuration
ConfigMap
yamlapiVersion: v1
kind: ConfigMap
metadata:
  name: web-config
data:
  # Simple key-value pairs
  API_URL: "https://api.example.com"
  FEATURE_FLAG_NEW_UI: "true"
  CACHE_TTL: "3600"
  
  # Complete configuration file
  config.json: |
    {
      "database": {
        "host": "db.example.com",
        "port": 5432,
        "name": "myapp"
      },
      "redis": {
        "host": "redis.example.com",
        "port": 6379
      }
    }
Pod Using the ConfigMap
yamlapiVersion: v1
kind: Pod
metadata:
  name: webapp
spec:
  containers:
  - name: app
    image: mywebapp:1.0
    # Environment variables
    env:
    - name: API_URL
      valueFrom:
        configMapKeyRef:
          name: web-config
          key: API_URL
    - name: FEATURE_FLAG_NEW_UI
      valueFrom:
        configMapKeyRef:
          name: web-config
          key: FEATURE_FLAG_NEW_UI
    # Mount config file
    volumeMounts:
    - name: config
      mountPath: /app/config
  volumes:
  - name: config
    configMap:
      name: web-config
      items:
      - key: config.json
        path: config.json
Managing ConfigMaps
View ConfigMaps
bash# List all ConfigMaps
kubectl get configmap

# View ConfigMap contents
kubectl describe configmap app-config

# Get as YAML
kubectl get configmap app-config -o yaml
Update ConfigMap
bash# Edit directly
kubectl edit configmap app-config

# Or replace from file
kubectl apply -f configmap.yaml
Important: Pods don't automatically reload when ConfigMap changes. You need to:

Restart the pod, OR
Use a sidecar to watch for changes, OR
Use tools like Reloader

Delete ConfigMap
bashkubectl delete configmap app-config
ConfigMap vs Secret
ConfigMapSecretNon-sensitive dataSensitive data (passwords, tokens)Stored as plain textBase64 encoded (not encrypted by default)Visible in kubectl getHidden in kubectl getExamples: API URLs, feature flagsExamples: DB passwords, API keys
Common Use Cases

Application Settings

yaml   data:
     LOG_LEVEL: "info"
     TIMEOUT: "30"

Feature Flags

yaml   data:
     ENABLE_BETA_FEATURE: "true"
     MAX_UPLOAD_SIZE: "10MB"

Configuration Files

yaml   data:
     redis.conf: |
       maxmemory 256mb
       maxmemory-policy allkeys-lru

Environment-Specific Config

yaml   # configmap-dev.yaml
   data:
     ENV: "development"
     API_URL: "http://localhost:8080"
   
configmap-prod.yaml
   data:
     ENV: "production"
     API_URL: "https://api.example.com"
Best Practices
✅ Use ConfigMaps for non-sensitive data
✅ Keep ConfigMaps small (< 1MB)
✅ One ConfigMap per application or concern
✅ Version your ConfigMaps (e.g., app-config-v1, app-config-v2)
✅ Use Secrets for passwords, not ConfigMaps
##### Step-01: Introduction
- We are going to create a MySQL Database with persistence storage using AWS EBS Volumes

| Kubernetes Object  | YAML File |
| ------------- | ------------- |
| Storage Class  | 01-storage-class.yml |
| Persistent Volume Claim | 02-persistent-volume-claim.yml   |
| Config Map  | 03-UserManagement-ConfigMap.yml  |
| Deployment, Environment Variables, Volumes, VolumeMounts  | 04-mysql-deployment.yml  |
| ClusterIP Service  | 05-mysql-clusterip-service.yml  |

##### Step-02: Create following Kubernetes manifests
###### Create Storage Class manifest
- https://kubernetes.io/docs/concepts/storage/storage-classes/#volume-binding-mode
- **Important Note:** `WaitForFirstConsumer` mode will delay the volume binding and provisioning  of a PersistentVolume until a Pod using the PersistentVolumeClaim is created. 

###### Create Persistent Volume Claims manifest
```
# Create Storage Class & PVC
kubectl apply -f kube-manifests/

# List Storage Classes
kubectl get sc

# List PVC
kubectl get pvc 

# List PV
kubectl get pv
```
###### Create ConfigMap manifest
- We are going to create a `usermgmt` database schema during the mysql pod creation time which we will leverage when we deploy User Management Microservice. 

###### Create MySQL Deployment manifest
- Environment Variables
- Volumes
- Volume Mounts

###### Create MySQL ClusterIP Service manifest
- At any point of time we are going to have only one mysql pod in this design so `ClusterIP: None` will use the `Pod IP Address` instead of creating or allocating a separate IP for `MySQL Cluster IP service`.   

##### Step-03: Create MySQL Database with all above manifests
```
# Create MySQL Database
kubectl apply -f kube-manifests/

# List Storage Classes
kubectl get sc

# List PVC
kubectl get pvc 

# List PV
kubectl get pv

# List pods
kubectl get pods 

# List pods based on  label name
kubectl get pods -l app=mysql
```

##### Step-04: Connect to MySQL Database
```
# Connect to MYSQL Database
kubectl run -it --rm --image=mysql:5.6 --restart=Never mysql-client -- mysql -h mysql -pdbpassword11

[or]

# Use mysql client latest tag
kubectl run -it --rm --image=mysql:latest --restart=Never mysql-client -- mysql -h mysql -pdbpassword11

# Verify usermgmt schema got created which we provided in ConfigMap
mysql> show schemas;
```

##### Step-05: References
- We need to discuss references exclusively here. 
- These will help you in writing effective templates based on need in your environments. 
- Few features are still in alpha stage as on today (Example:Resizing), but once they reach beta you can start leveraging those templates and make your trials. 
- **EBS CSI Driver:** https://github.com/kubernetes-sigs/aws-ebs-csi-driver
- **EBS CSI Driver Dynamic Provisioning:**  https://github.com/kubernetes-sigs/aws-ebs-csi-driver/tree/master/examples/kubernetes/dynamic-provisioning
- **EBS CSI Driver - Other Examples like Resizing, Snapshot etc:** https://github.com/kubernetes-sigs/aws-ebs-csi-driver/tree/master/examples/kubernetes
- **k8s API Reference Doc:** https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.18/#storageclass-v1-storage-k8s-io

- To list the storage classes in your cluster, run:
```kubectl get storageclass```
- To view detailed information about a specific storage class, run:
```kubectl describe storageclass <storage-class-name>```
- To list the persistent volume claims (PVCs) in your cluster, run:
```kubectl get pvc```
- To view detailed information about a specific PVC, run:
```kubectl describe pvc <pvc-name>```
- To list the configmaps in your cluster, run:
```kubectl get configmap```
- To view detailed information about a specific configmap, run:
```kubectl describe configmap <configmap-name>```
- /docker-entrypoint-initdb.d is a special directory in the MySQL Docker image.
- Any .sql or .sh files placed in this directory will be automatically executed when the MySQL container is started for the first time.
- This is useful for initializing the database with custom schemas, tables, or data.
- Once the persistent volume is created is attached to the MySQL pod, the data stored in the database will persist even if the pod is deleted or recreated.
- The volume is attached to the node where the pod is scheduled, and the data remains intact as long as the volume exists.
- To list pods with a specific label run:
```kubectl get pods -l <label-key>=<label-value>```
- Example:
```kubectl get pods -l app=mysql```
- To access the MySQL database from within the cluster, you can use the MySQL client image to create a temporary pod that connects to the MySQL service.
- The command `kubectl run -it --rm --image=mysql:5.6 --restart=Never mysql-client -- mysql -h mysql -pdbpassword11` creates a temporary pod named `mysql-client` using the MySQL 5.6 image.
- The `--restart=Never` flag ensures that the pod is not restarted after it exits.
- The `--rm` flag ensures that the pod is deleted after you exit the MySQL client.
- The command `mysql -h mysql -pdbpassword11` connects to the MySQL service using the hostname `mysql` and the password `dbpassword11`.

#### Creating kubernetes Manifest for user management microservice deployment:
- All files for this hands on are located are EKS\yaml-files\class-yaml-files\04-03-UserManagement-MicroService-with-MySQLDB
What is Postman?
Postman is a tool that lets you send requests to APIs and see the responses - like a sophisticated web browser, but for developers testing backends instead of visiting websites.
How It Works - Simple Analogy
Think of Postman like a mail carrier (hence the name!):

You write a letter (HTTP request)
Address it to someone (API endpoint URL)
Send it off (click Send)
Get a response back (API response)

Basic Workflow
1. You create a request:
Method: GET, POST, PUT, DELETE, etc.
URL: http://api.example.com/users
Headers: Authentication tokens, content-type, etc.
Body: Data you're sending (for POST/PUT)
2. Click "Send"
3. Get a response:
Status: 200 OK, 404 Not Found, 500 Error, etc.
Body: JSON data, HTML, XML, etc.
Time: How long it took
Real Example - Testing a MySQL API on EKS
Let's say you deployed an API application in EKS that connects to your MySQL database:
┌──────────┐      HTTP Request       ┌─────────────┐
│ Postman  │ ───────────────────────>│   EKS Pod   │
│ (Laptop) │                         │  (Your API) │
└──────────┘      HTTP Response      └─────────────┘
                <───────────────────        │
                                             │ Queries
                                             ▼
                                      ┌─────────────┐
                                      │ MySQL Pod   │
                                      │ (Database)  │
                                      └─────────────┘
Example Request in Postman:
Method: POST
URL: http://your-eks-loadbalancer.com/api/users
Headers:
  Content-Type: application/json
  Authorization: Bearer your-token-here
Body:
{
  "name": "John Doe",
  "email": "john@example.com"
}
What happens:

Postman sends this HTTP request to your EKS load balancer
Request routes to your API pod
Your API pod processes it and inserts data into MySQL
API pod sends response back
Postman displays the response

Response you might see:
jsonStatus: 201 Created
Body:
{
  "id": 123,
  "name": "John Doe",
  "email": "john@example.com",
  "created_at": "2025-12-30T10:30:00Z"
}
```

## Key Features

**Collections:** Group related requests together
```
My API Tests/
├── User Management/
│   ├── Create User (POST)
│   ├── Get User (GET)
│   ├── Update User (PUT)
│   └── Delete User (DELETE)
└── Authentication/
    ├── Login (POST)
    └── Logout (POST)
```

**Environment Variables:** Store values like URLs, tokens
```
Development: http://dev-api.com
Staging: http://staging-api.com
Production: http://api.com
Tests: Automated checks
javascript// Check if status is 200
pm.test("Status is 200", function () {
    pm.response.to.have.status(200);
});

// Check if response contains expected data
pm.test("User created", function () {
    pm.expect(pm.response.json().name).to.eql("John Doe");
});
Why Use Postman with EKS?
When you deploy applications to EKS, you need to test:

✅ Are my API endpoints accessible?
✅ Is authentication working?
✅ Is data being saved to MySQL correctly?
✅ Are my services communicating properly?

Postman makes this testing quick and visual instead of writing curl commands in terminal.
Alternative: cURL
Postman is essentially a GUI for what you could do with cURL:
Postman way: Click buttons, fill forms
cURL way:
bashcurl -X POST http://your-api.com/users \
  -H "Content-Type: application/json" \
  -d '{"name":"John Doe","email":"john@example.com"}'
Both do the same thing - Postman is just more user-friendly!
Does this help clarify how Postman works?
What Browsers Can Do vs. What Postman Can Do
Browsers - Limited to GET Requests
When you type a URL in your browser and press Enter, you're only sending a GET request.
Browser: http://api.example.com/users
↓
Sends: GET request
↓
Shows: The response page
APIs Need More Than GET
Most APIs require different HTTP methods that browsers can't easily do:
GET - Retrieve data ✅ Browser can do this
POST - Create new data ❌ Browser can't easily do this
PUT - Update existing data ❌ Browser can't do this
DELETE - Remove data ❌ Browser can't do this
Real-World Example
Let's say you have a user management API on EKS:
Using Browser (Limited)
✅ http://api.example.com/users
   → Shows list of users (GET works!)

❌ Can't create a new user (needs POST)
❌ Can't update a user (needs PUT)  
❌ Can't delete a user (needs DELETE)
❌ Can't send authentication tokens easily
❌ Can't send JSON data in request body
Using Postman (Full Control)
✅ GET http://api.example.com/users
   → Retrieve users

✅ POST http://api.example.com/users
   Body: {"name": "John", "email": "john@example.com"}
   → Create new user

✅ PUT http://api.example.com/users/123
   Body: {"name": "John Updated"}
   → Update user

✅ DELETE http://api.example.com/users/123
   → Delete user
Specific Limitations of Browsers
1. Can't Send Custom Headers Easily
API requires: Authorization: Bearer abc123token
Browser: No easy way to add this
Postman: Add in Headers section
2. Can't Send JSON Body
API expects: {"username": "admin", "password": "secret"}
Browser: Can't send this in a GET request
Postman: Add in Body section
3. Can't Test Different Methods
Browser form: Only GET or POST (and POST requires HTML form)
Postman: GET, POST, PUT, PATCH, DELETE, HEAD, OPTIONS, etc.
When Browser IS Enough
Browsers work fine for:

✅ Simple public APIs returning JSON (GET only)
✅ Checking if an endpoint is reachable
✅ Viewing rendered web pages

Example that works in browser:
http://api.example.com/users
→ Returns: [{"id":1,"name":"John"},{"id":2,"name":"Jane"}]
When You NEED Postman
You need Postman when:

❌ Testing login endpoints (POST with credentials)
❌ Creating/updating/deleting data
❌ Sending authentication tokens
❌ Testing protected endpoints
❌ Sending complex JSON payloads
❌ Need to see detailed response headers, status codes, timing

Practical EKS Example
Your MySQL API on EKS has a login endpoint:
Browser approach (doesn't work):
http://your-eks-lb.com/api/login
→ Error: Method not allowed (needs POST, not GET)
Postman approach (works):
POST http://your-eks-lb.com/api/login
Headers:
  Content-Type: application/json
Body:
{
  "username": "admin",
  "password": "secret123"
}
Response:
{
  "token": "eyJhbGciOiJIUzI1NiIs...",
  "user": {"id": 1, "name": "Admin"}
}
Summary
Browser = Read-only viewer (mostly GET requests)
Postman = Full API testing tool (all HTTP methods, headers, auth, etc.)
Think of it this way:

Browser is like a TV remote that only has an "ON" button
Postman is like a full control panel with every button you need

#### k8s Secrets, Init Containers, Liveness and Readiness Probes and Request Limits:
##### Secrets:
- Kubernetes Secrets are used to store sensitive information, such as passwords, OAuth tokens, and ssh keys.
- Storing such information in a Secret is safer and more flexible than putting it verbatim in a Pod definition or in a container image.
- Kubernetes Secrets let you store and manage sensitive information separately from your application code.
- This way, you can keep your sensitive data secure and easily update it without changing your application.
- Secrets are encoded in base64 format to provide a basic level of obfuscation, but they are not encrypted by default.
- To create a secret from literal values, you can use the following command:
```bashkubectl create secret generic my-secret \
  --from-literal=username=myuser \
  --from-literal=password=mypassword
```
- To encode a passsword to base64 in powershell use the following command 
```powershell[Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes("dbpassword11"))```
- This will create an encoded version of the password that you can use in your secret manifest.
- You can also use the url https://www.base64encode.org/ to encode and decode base64 strings.