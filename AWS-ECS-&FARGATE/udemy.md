Course Prerequisites:
- Dockerfile, creating images 
- Running containers
- Port mappings
- Push and pull from repository 
- Volume mounting 
- basic knowledge of aws 
- aws networking
- IAM roles and permissions

Docker:
- The docker daemon allows for the management of Docker containers, images, networks, and volumes on a host system. It listens for API requests from clients and handles the creation, execution, and orchestration of containers.
- it works with the docker agent to manage the containers on the host.
- The containers can talk to each other over a virtual network created by Docker.
- Docker images are stored in docker repositories. ex docker hub
- Amazon has its own private repository service called Amazon ECR (Elastic Container Registry).
- Docker Hub is a public registry that anyone can use to share their Docker images.
- Whats the difference between Docker and virtual machine
- Docker containers are lightweight and share the host OS kernel, while virtual machines include the entire OS and are more resource-intensive.
- For virtual machine you install the guest os on top of the host os using the hypervisor.
- The docker daemon is installed on the host os and it manages the containers.
- With the hypervisor you are limited to the os you install on the vm
- Each VM runs its own OS kernel on top of the hypervisor.
- Efficient scaling: You can run many more containers on the same hardware vs VMs.
- The docker daemon allows for the management of Docker containers, images, networks, and volumes on a host system. It listens for API requests from clients and handles the creation, execution, and orchestration of containers.

What is ECS:
 - It stands for Elastic Container Service.
 - We use ECS to launch container services.
 - For ECS you provision and maintain the infrastructure but aws takes care of starting and stopping the containers.
 - ECS knows where to add the server resources based on demand but you still need to manage those EC2 instances manually
 - You can integrate application load balancers with ECS to distribute traffic across your containers.
 - It is a fully managed container orchestration service provided by AWS.
 - It allows you to run and manage Docker containers on a cluster of EC2 instances.
 - ECS takes care of the heavy lifting involved in deploying and managing containers, such as scaling, load balancing, and monitoring.

What is Fargate:
 - Still allows you to launch docker containers on AWS without managing the underlying infrastructure. This is done by AWS
 - AWS runs all the containers based on the cpu and ram that you need. 
 - All of this is done in the backend by AWS
 - It is a serverless compute engine for containers.
 - It allows you to run containers without having to manage the underlying infrastructure.
 - With Fargate, you don't need to provision or manage EC2 instances.
 - You only pay for the resources that your containers use.
 - Fargate automatically scales your containers based on demand.
 - It integrates with ECS and EKS (Elastic Kubernetes Service).
 - It is a good choice for applications with variable workloads or unpredictable traffic patterns.
