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

ECS VS EKS VS Beanstalk:
 - ECS is a container orchestration service for managing Docker containers on a cluster of EC2 instances.
 - EKS is a managed Kubernetes service for running Kubernetes clusters on AWS. Docker on AWS but running on Kubernetes. Open source tool for container orchestration.
 - Beanstalk is a platform as a service (PaaS) for deploying and managing applications without worrying about the underlying infrastructure.
 
ECS Clusters:
- ECS Clusters are a logical grouping of EC2 instances or Fargate tasks where you can run your containerized applications.
- You can have multiple clusters for different environments (e.g., dev, staging, prod) or applications.
- Each cluster can contain one or more services and tasks.
- Clusters help you organize and manage resources, networking, and security boundaries for your containers.
- EC2 instances run the ECS agent(Docker container)
- The ECS Agents register the instances to the ECS Cluster
- The EC2 instances Run a special AMI made specifically for ECS.
- There are 4 roles to make note of: 
- There is an ecs-instance-role which allows ec2 instances in an ECS cluster to access ECS and ecs-role which allows ECS to create and manage AWS resources on your behalf
- The ecs-instance-role is attached to the EC2 instances running in the ECS cluster, while the ecs-role is used by the ECS service itself.
- The ecs-instance-role typically has permissions to pull container images from Amazon ECR, log to Amazon CloudWatch, and communicate with the ECS service.
- The ecs-role typically has permissions to create and manage AWS resources on your behalf, such as creating load balancers, scaling groups, and other resources needed for your containerized applications.
- The ecs-instance-role is used by the EC2 instances in the ECS cluster, while the ecs-role is used by the ECS service itself.
- The ecs-role is typically assumed by the ECS service when it needs to create or manage AWS resources on your behalf.
- The ecs-role is also used to grant permissions to other AWS services that need to interact with your ECS tasks and services.
- The ecs-role is created with the necessary permissions and trust relationships to allow the ECS service to assume it.
- The ecs-instance-role has a trust relationship with ec2.amazonaws.com, allowing EC2 instances to assume the role.
- There is a ecs-task execution role which allows ECS tasks to call AWS services on your behalf.
- The role has a trust with ecs-tasks.amazonaws.com, allowing ECS tasks to assume the role.
- Last role is the ecs-autoscaling role which allows Auto Scaling to access and update ECS services.

An Amazon ECS cluster is basically a logical group of compute resources (either EC2 instances or Fargate tasks) where your Docker containers run.
Think of it like this:
ECS (Elastic Container Service) is AWS’s container orchestration service (similar to Kubernetes, but managed by AWS).
An ECS Cluster is a pool of resources where you deploy your containerized applications.
Key points about an ECS Cluster:
It doesn’t run anything by itself — it’s just the grouping mechanism.
You choose how the cluster is backed:
EC2 Launch Type → Your containers run on EC2 instances you manage.
Fargate Launch Type → AWS manages the servers for you (serverless containers).
Inside the cluster, you run:
Tasks → A single running copy of a container (or multiple containers defined together in a task definition).
Services → A way to keep a set number of tasks running (like “always keep 3 replicas of this web app running”).
ECS integrates with ALBs/NLBs for load balancing and CloudWatch for logging/metrics.
Clusters can span multiple Availability Zones in a region, giving you high availability.
Creating an EC2 based cluster:
1. Open the Amazon ECS console.
2. Choose "Clusters" from the navigation pane.
3. Choose "Create Cluster".
4. Select "EC2 Linux + Networking" or "EC2 Windows + Networking" depending on your needs.
5. Configure the cluster settings, including the cluster name, instance type, and number of instances.
6. Choose "Create" to create the cluster.
- The ec2 instance shows under infrastructure under the cluster
- You can view and manage your cluster resources from the ECS console.


Creating a Fargate based cluster:
1. Open the Amazon ECS console.
2. Choose "Clusters" from the navigation pane.
3. Choose "Create Cluster".
4. Select "Fargate" as the launch type.
5. Configure the cluster settings, including the cluster name and any other options.
6. Choose "Create" to create the cluster.
- The Fargate tasks will run without the need for EC2 instances.
- You can view and manage your cluster resources from the ECS console.

ECS Task Definition:
    - This is the blueprint of our container
    - Written in JSON or YAML format
    - it contains crucial information like image name, port binding for container and host, environment variables, cpu and memory requirements, networking mode, logging configuration, and IAM roles.
    - You need the ecs instance role to allow the ecs agent to register itself to the ecs service
EC2 instance profile:
    - Used by the ECS agent to make API calls to the ECS service.
    - Send container logs to cloudwatch logs 
    - Pull Docker images from ECR
ECS Task role: 
    - Allow each task to have a specific role 
    - Use different roles for different ECS service you run 
    - Task roles is defined in the task definition 
    - Allows the container to interact with other AWS services.
    - You can specify the task role in the task definition.
    - The task role is assumed by the containers in the task.
ECS Service:
    - ECS service helps define how many tasks should run and how they should run 
    - They ensure that the number of tasks desired is running across our fleet of ec2 instances 
    - They can be linked to a load balancer for distributing traffic
    - You can run a task without ECS service but it is not recommended for production workloads in case you want to scale your application.
    - ECS services can also be configured to use service discovery for easier communication between services.
Task definition:
    - A task definition is a blueprint for your application.
    - It specifies the container images to use, CPU and memory requirements, networking mode, and IAM roles.
    - Task definitions are written in JSON or YAML format.
    - You can version your task definitions, allowing you to roll back to previous versions if needed.
    - To create a task definition, you can use the AWS Management Console, AWS CLI, or SDKs.
    - Using the console:
        1. Open the Amazon ECS console.
        2. Choose "Task Definitions" from the navigation pane.
        3. Choose "Create new Task Definition".
        4. Select the launch type (EC2 or Fargate).
        5. Configure the task definition settings, including container definitions, resource requirements, and IAM roles.
        6. Choose "Create" to create the task definition.
    - Example task definition (in JSON format):
{
  "compatibilities": [
    "EC2",
    "FARGATE"
  ],
  "containerDefinitions": [
    {
      "cpu": 0,
      "environment": [],
      "environmentFiles": [],
      "essential": true,
      "image": "pauloclouddev/wisdom-img",
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/ecs-td",
          "awslogs-create-group": "true",
          "awslogs-region": "us-east-1",
          "awslogs-stream-prefix": "ecs"
        },
        "secretOptions": []
      },
      "mountPoints": [],
      "name": "siomple-api",
      "portMappings": [
        {
          "appProtocol": "http",
          "containerPort": 80,
          "hostPort": 80,
          "name": "siomple-api-80-tcp",
          "protocol": "tcp"
        }
      ],
      "systemControls": [],
      "ulimits": [],
      "volumesFrom": []
    }
  ],
  "cpu": "256",
  "enableFaultInjection": false,
  "executionRoleArn": "arn:aws:iam::730335294148:role/ecsTaskExecutionRole",
  "family": "ecs-td",
  "memory": "512",
  "networkMode": "awsvpc",
  "placementConstraints": [],
  "registeredAt": "2025-08-31T00:35:05.001Z",
  "registeredBy": "arn:aws:sts::730335294148:assumed-role/AWSReservedSSO_AdministratorAccess_3d0f46907c18b968/Brigthain",
  "requiresAttributes": [
    {
      "name": "com.amazonaws.ecs.capability.logging-driver.awslogs"
    },
    {
      "name": "ecs.capability.execution-role-awslogs"
    },
    {
      "name": "com.amazonaws.ecs.capability.docker-remote-api.1.19"
    },
    {
      "name": "com.amazonaws.ecs.capability.task-iam-role"
    },
    {
      "name": "com.amazonaws.ecs.capability.docker-remote-api.1.18"
    },
    {
      "name": "ecs.capability.task-eni"
    },
    {
      "name": "com.amazonaws.ecs.capability.docker-remote-api.1.29"
    }
  ],
  "requiresCompatibilities": [
    "FARGATE"
  ],
  "revision": 2,
  "runtimePlatform": {
    "cpuArchitecture": "X86_64",
    "operatingSystemFamily": "LINUX"
  },
  "status": "ACTIVE",
  "taskDefinitionArn": "arn:aws:ecs:us-east-1:730335294148:task-definition/ecs-td:2",
  "taskRoleArn": "arn:aws:iam::730335294148:role/ecs-task-execution-role",
  "volumes": [],
  "tags": []
}
JSON

CloudShell
Feedback
- You can use CloudShell to run aws cli commands without having to install the cli on your local machine.
Creating a task:
 - To create a task using the AWS console, follow these steps:
    1. Open the Amazon ECS console.
    2. Choose "Clusters" from the navigation pane.
    3. Select the cluster where you want to run the task.
    4. Choose the "Tasks" tab.
    5. Click on "Run new Task".
    6. Select the launch type (EC2 or Fargate).
    7. Choose the task definition you want to use.
    8. Configure the task settings, including the number of tasks, networking, and IAM roles.
    9. Click on "Run Task" to start the task.
- Network mode bridge means that the container will share the host's network stack, allowing it to communicate with other containers and the host using localhost.
🔹 Bridge Mode in ECS
Your container runs behind the Docker daemon’s NAT bridge network on the EC2 host.
The container does not get its own ENI (Elastic Network Interface). Instead, it shares the host’s ENI.
ECS manages port mappings between the container and the host.
Example:
Container listens on port 80
ECS can map it to host port 32768 (dynamic)
Traffic → Host ENI:32768 → Container:80
🔹 Characteristics
✅ Good for multiple containers per EC2 host (you can map different host ports → same container port across tasks).
✅ Works in EC2 launch type.
❌ Not supported in Fargate (Fargate only supports awsvpc).
❌ Can be harder to manage security and service discovery, because containers don’t have their own IP addresses.
🔹 Comparison with other modes
awsvpc (preferred now): Each task gets its own ENI + IP in the VPC. Best for isolation & security. Required in Fargate.
host: Container uses the host’s network stack directly (no port mapping, container port = host port).
bridge: Containers sit behind Docker’s NAT bridge; requires explicit port mapping.
👉 In ECS, you’ll mostly see bridge mode in older EC2-based clusters or when you need port-mapped, NAT-style networking.
👉 For new deployments (especially with Fargate), AWS strongly recommends awsvpc mode.
In awsvpc mode:
Each task (not just the container) gets its own Elastic Network Interface (ENI) in the VPC.
That ENI has its own private IP address (and public IP if you assign one).
Containers inside the task can listen directly on their ports (like port 80 or 443) — no need for host port mapping.
Example
You run a container with a web app on port 80.
ECS gives the task its own IP: 10.0.2.45.
You can reach it directly at 10.0.2.45:80.
No need to map through the EC2 host like in bridge mode.
Why it’s useful
✅ Each task is like its own mini virtual machine on the network.
✅ Security groups can be attached per task, not just at the EC2 instance level.
✅ Works perfectly with Fargate (since tasks run without you managing EC2s).
So yeah — in awsvpc you just use the task’s IP and container port directly, instead of doing port juggling like in bridge.

ECS Task placement Process:
- When a task is launched, ECS evaluates the available resources in the cluster.
- It considers factors like CPU, memory, and any task placement constraints.
- ECS then places the task on an appropriate container instance (for EC2 launch type) or provisions a new Fargate task.
- ECS needs to figure out the best placement strategy based on the task requirements and cluster resources.
- This only works for ec2 launch type and not fargate 
- Task placement strategies are best effort
- when amazon ecs places tasks, it uses the following process to select a container instances:
  1. Identify the instances that satisfy the cpu, memory and port requirements in the task definition
  2. Identify the instances that satisfy the task placement constraints
  3. Identify the instances that satisfy the task placement strategies
  4. Select onf of the instances for task placement 

ECS Task placement strategies:
- binpack: Place tasks based on the least available amount of CPU/Memory. This is useful for maximizing resource utilization.
- spread: Distribute tasks evenly across all available instances. This is useful for high availability.
- random: Place tasks on any available instance. This is useful for testing and development.
- They can all be mixed and matched based on your needs.

ECS Task placement constraints:
- distinctInstance: Place tasks on distinct container instances. This is useful for spreading tasks across multiple instances.
- memberOf: Place tasks on instances that are part of a specific capacity provider or cluster.
- maxPods: Limit the number of tasks that can be placed on a single instance.

ECS Networking modes:
- bridge: The default networking mode. Containers get an internal IP address and communicate with the host using port mappings.
- host: Containers share the host's network stack. This means they can communicate with each other using localhost. Use this for extreme network performance. 
- awsvpc: Each task gets its own ENI and IP address. This is the preferred mode for Fargate. Each task receives a unique IP and ENI, allowing direct network access and improved isolation. No port mapping is required—containers can listen on any port. This mode provides the highest network performance and security. For EC2 launch type, the number of tasks is limited by the number of available ENIs on the instance. So check the number of ENIs per instance type. Make sure your vpc has lots of ip addresses. 
- none: No networking. Containers cannot communicate with each other or the host.

Load balancing for ECS:
- We use Bridge Networing mode and we get a dynamic port mapping 
- The ALB supports finding the right port on your ec2 instances 
- You must allow on the ec2 instance security group any ports from the ALB 

Load balancing for Fargate:
- We use awsvpc networking mode, so each task gets its own ENI and IP address.
- The ALB can route traffic directly to the task's IP and port.
- You must allow on the task's security group any ports from the ALB.
