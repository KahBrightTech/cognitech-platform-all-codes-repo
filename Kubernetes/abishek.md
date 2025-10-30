# Kubernetes beginners to experts - Abishek's Notes
### Difference between Docker and Kubernetes?
**Docker** is a containers platform that allows you to create, deploy, and run applications in containers. Kubernetes is a container orchestration platform that automates the deployment, scaling, and management of containerized applications.
**Kubernetes** is a container orchestration tool that can work with different container runtimes, including Docker.

**What does it mean to be a container orchestration tool?**
Container orchestration tools like Kubernetes manage the lifecycle of containers, including deployment, scaling, networking, and monitoring. They help ensure that containers are running as expected and can handle failures and updates seamlessly.

### 🔄 Container Nature

**Containers are ephemeral in nature** meaning they are short-lived and can be created and destroyed quickly.

### ⚠️ Problems with Docker Alone

- **Single host hence single point of failure**: If one container fails, all other containers go down as well.
- **Auto healing is not possible**: This requires manual intervention in Docker.
- **Auto scaling is not possible**: This can be problematic during high traffic. Not only are containers scaled, they must also be load balanced.
- **Limited enterprise features**: Docker is a very simple platform that does not support enterprise level standards such as load balancing, firewall, autoscaling, auto healing, API gateway and much more.

### ✅ How Kubernetes Solves These Problems

- **High Availability**: Kubernetes can manage multiple hosts, providing high availability and fault tolerance. Kubernetes is a cluster (group of nodes) of machines that work together to run containerized applications. So if one node goes down, other nodes can take over the workload.

- **Auto Healing**: Kubernetes has built-in auto healing capabilities that can automatically restart or replace failed containers. Kubernetes either controls or fixes the failed containers without any manual intervention.

- **Auto Scaling**: Kubernetes supports auto scaling, allowing applications to handle varying levels of traffic efficiently. This is done through replica sets or replication controller that ensure a specified number of container replicas are always running.

- **Enterprise Features**: Kubernetes provides a comprehensive set of features for enterprise-level container management, including load balancing, networking. Docker is never used in production because it is not an enterprise level platform.

### 🏗️ Kubernetes Architecture

#### Why "k8s"?

The word Kubernetes has 10 letters: K + u b e r n e t e s.
The abbreviation "k8s" replaces the 8 letters between the first and last letter with the number 8.

Kubernetes has the **control plane** and the **data plane**.

#### 🎛️ Control Plane Components

- **API Server**: The API server is the front-end of the Kubernetes control plane. It exposes the Kubernetes API and serves as the main entry point for all administrative tasks. It processes RESTful requests, validates them, and updates the corresponding objects in the etcd datastore.

- **etcd**: etcd is a distributed key-value store that serves as the backing store for all cluster data. It stores the configuration data, state information, and metadata about the cluster and its resources. This exposes kubernetes to the external world.

- **Controller Manager**: The controller manager is responsible for managing various controllers that monitor the state of the cluster. Controllers are control loops that ensure the desired state of the cluster matches the actual state. Examples of controllers include the replication controller, node controller, and endpoint controller.

- **Scheduler**: The scheduler is responsible for assigning pods to nodes based on resource availability and other constraints. It evaluates the resource requirements of pods and the available resources on nodes to make scheduling decisions.

- **Cloud Controller Manager**: The cloud controller manager is responsible for managing cloud-specific resources and integrating with cloud provider APIs. It allows Kubernetes to interact with cloud services such as load balancers, storage, and networking. This is not needed if running k8s on-premise.

#### 💻 Data Plane Components (Worker Nodes)

The data plane consists of worker nodes that run the containerized applications. Each worker node has the following components:

- **Kubelet**: The kubelet is an agent that runs on each worker node. It is responsible for managing the lifecycle of pods and containers on the node. The kubelet communicates with the API server to receive instructions and report the status of the node and its pods.

- **Kube-proxy**: The kube-proxy is a network proxy that runs on each worker node. It is responsible for maintaining network rules and facilitating communication between pods and services within the cluster. This provides IP address translation and load balancing for network traffic. It uses iptables or IPVS to manage network rules.

- **Container Runtime**: The container runtime is the software responsible for running containers on the worker nodes. Kubernetes supports various container runtimes, including Docker, containerd, and CRI-O.

### 📊 Kubernetes Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                              KUBERNETES CLUSTER                                │
└─────────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────────┐
│                                CONTROL PLANE                                   │
│                              (Master Node)                                     │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                                 │
│  ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐             │
│  │   API SERVER    │    │      etcd       │    │   SCHEDULER     │             │
│  │                 │    │                 │    │                 │             │
│  │ • REST API      │    │ • Key-Value     │    │ • Pod Placement │             │
│  │ • Authentication│◄──►│   Store         │    │ • Resource      │             │
│  │ • Authorization │    │ • Cluster State │    │   Allocation    │             │
│  │ • Validation    │    │ • Configuration │    │ • Constraints   │             │
│  │ • Entry Point   │    │ • Backup Data   │    │ • Affinity      │             │
│  └─────────────────┘    └─────────────────┘    └─────────────────┘             │
│           │                       ▲                       ▲                    │
│           │                       │                       │                    │
│           ▼                       │                       │                    │
│  ┌─────────────────┐              │                       │                    │
│  │ CONTROLLER      │              │                       │                    │
│  │    MANAGER      │──────────────┘                       │                    │
│  │                 │                                      │                    │
│  │ • Node Controller        ┌─────────────────┐           │                    │
│  │ • Replication           │  CLOUD CONTROLLER│           │                    │
│  │   Controller            │     MANAGER      │           │                    │
│  │ • Endpoint              │                  │           │                    │
│  │   Controller            │ • Load Balancers │           │                    │
│  │ • Service Account       │ • Storage Classes│           │                    │
│  │   Controller            │ • Cloud Specific │           │                    │
│  │ • Job Controller        │   Resources      │           │                    │
│  └─────────────────┘       └─────────────────┘           │                    │
│                                                           │                    │
└───────────────────────────────────────────────────────────┼────────────────────┘
                                                            │
                                    ┌───────────────────────┼────────────────────┐
                                    │                       ▼                    │
                                    │              NETWORK LAYER                 │
                                    │                                            │
                                    │  ┌─────────────────────────────────────┐   │
                                    │  │          SERVICE MESH               │   │
                                    │  │     • Load Balancing               │   │
                                    │  │     • Service Discovery           │   │
                                    │  │     • Traffic Management          │   │
                                    │  └─────────────────────────────────────┘   │
                                    └────────────────────────────────────────────┘
                                                            │
┌───────────────────────────────────────────────────────────┼────────────────────┐
│                                DATA PLANE                 │                    │
│                            (Worker Nodes)                 ▼                    │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                                 │
│ ┌─────────────────────────────────────────────────────────────────────────────┐ │
│ │                             WORKER NODE 1                                  │ │
│ ├─────────────────────────────────────────────────────────────────────────────┤ │
│ │                                                                             │ │
│ │  ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐         │ │
│ │  │     KUBELET     │    │   KUBE-PROXY    │    │   CONTAINER     │         │ │
│ │  │                 │    │                 │    │    RUNTIME      │         │ │
│ │  │ • Pod Lifecycle │    │ • Network Proxy │    │                 │         │ │
│ │  │ • Container     │    │ • Load Balancing│    │ • Docker        │         │ │
│ │  │   Management    │    │ • Service       │    │ • containerd    │         │ │
│ │  │ • Node Status   │    │   Discovery     │    │ • CRI-O         │         │ │
│ │  │ • Health Checks │    │ • iptables Rules│    │ • rkt           │         │ │
│ │  │ • Resource      │    │ • Port Forward  │    │                 │         │ │
│ │  │   Monitoring    │    │                 │    │                 │         │ │
│ │  └─────────────────┘    └─────────────────┘    └─────────────────┘         │ │
│ │           │                       │                       │                │ │
│ │           └───────────────────────┼───────────────────────┘                │ │
│ │                                   │                                        │ │
│ │  ┌─────────────────────────────────▼─────────────────────────────────────┐  │ │
│ │  │                              PODS                                     │  │ │
│ │  ├────────────────┬────────────────┬────────────────┬────────────────────┤  │ │
│ │  │   APP POD 1    │   APP POD 2    │   APP POD 3    │   SYSTEM POD       │  │ │
│ │  │                │                │                │                    │  │ │
│ │  │ ┌────────────┐ │ ┌────────────┐ │ ┌────────────┐ │ ┌────────────────┐ │  │ │
│ │  │ │Container 1 │ │ │Container 1 │ │ │Container 1 │ │ │  Logging       │ │  │ │
│ │  │ │Container 2 │ │ │Container 2 │ │ │            │ │ │  Monitoring    │ │  │ │
│ │  │ └────────────┘ │ └────────────┘ │ └────────────┘ │ │  Network       │ │  │ │
│ │  │                │                │                │ └────────────────┘ │  │ │
│ │  └────────────────┴────────────────┴────────────────┴────────────────────┘  │ │
│ └─────────────────────────────────────────────────────────────────────────────┘ │
│                                                                                 │
│ ┌─────────────────────────────────────────────────────────────────────────────┐ │
│ │                             WORKER NODE 2                                  │ │
│ ├─────────────────────────────────────────────────────────────────────────────┤ │
│ │                                                                             │ │
│ │  ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐         │ │
│ │  │     KUBELET     │    │   KUBE-PROXY    │    │   CONTAINER     │         │ │
│ │  │                 │    │                 │    │    RUNTIME      │         │ │
│ │  │ • Pod Lifecycle │    │ • Network Proxy │    │                 │         │ │
│ │  │ • Container     │    │ • Load Balancing│    │ • Docker        │         │ │
│ │  │   Management    │    │ • Service       │    │ • containerd    │         │ │
│ │  │ • Node Status   │    │   Discovery     │    │ • CRI-O         │         │ │
│ │  │ • Health Checks │    │ • iptables Rules│    │ • rkt           │         │ │
│ │  │ • Resource      │    │ • Port Forward  │    │                 │         │ │
│ │  │   Monitoring    │    │                 │    │                 │         │ │
│ │  └─────────────────┘    └─────────────────┘    └─────────────────┘         │ │
│ │           │                       │                       │                │ │
│ │           └───────────────────────┼───────────────────────┘                │ │
│ │                                   │                                        │ │
│ │  ┌─────────────────────────────────▼─────────────────────────────────────┐  │ │
│ │  │                              PODS                                     │  │ │
│ │  ├────────────────┬────────────────┬────────────────┬────────────────────┤  │ │
│ │  │   APP POD 4    │   APP POD 5    │   APP POD 6    │   SYSTEM POD       │  │ │
│ │  │                │                │                │                    │  │ │
│ │  │ ┌────────────┐ │ ┌────────────┐ │ ┌────────────┐ │ ┌────────────────┐ │  │ │
│ │  │ │Container 1 │ │ │Container 1 │ │ │Container 1 │ │ │  Logging       │ │  │ │
│ │  │ │Container 2 │ │ │            │ │ │Container 2 │ │ │  Monitoring    │ │  │ │
│ │  │ └────────────┘ │ └────────────┘ │ │Container 3 │ │ │  Network       │ │  │ │
│ │  │                │                │ └────────────┘ │ └────────────────┘ │  │ │
│ │  └────────────────┴────────────────┴────────────────┴────────────────────┘  │ │
│ └─────────────────────────────────────────────────────────────────────────────┘ │
│                                                                                 │
│ ┌─────────────────────────────────────────────────────────────────────────────┐ │
│ │                             WORKER NODE N                                  │ │
│ │                              (More nodes...)                               │ │
│ └─────────────────────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────────┐
│                            EXTERNAL COMPONENTS                                 │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                                 │
│  ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐             │
│  │    KUBECTL      │    │   DASHBOARD     │    │   MONITORING    │             │
│  │                 │    │                 │    │                 │             │
│  │ • CLI Tool      │    │ • Web UI        │    │ • Prometheus    │             │
│  │ • API Client    │    │ • Cluster       │    │ • Grafana       │             │
│  │ • Resource      │    │   Management    │    │ • Metrics       │             │
│  │   Management    │    │ • Visual        │    │ • Alerting      │             │
│  │                 │    │   Interface     │    │                 │             │
│  └─────────────────┘    └─────────────────┘    └─────────────────┘             │
│                                                                                 │
└─────────────────────────────────────────────────────────────────────────────────┘
```

### Component Communication Flow:

1. **kubectl** → **API Server** (Commands and queries)
2. **API Server** → **etcd** (Store/retrieve cluster state)
3. **API Server** → **Scheduler** (Pod scheduling requests)
4. **API Server** → **Controller Manager** (State reconciliation)
5. **API Server** → **Kubelet** (Pod specifications)
6. **Kubelet** → **Container Runtime** (Container lifecycle)
7. **Kube-proxy** → **iptables/IPVS** (Network rules)
8. **Controllers** → **API Server** → **etcd** (Desired state loop)

### Key Responsibilities:

#### Control Plane Components:

- **API Server**: Central hub for all cluster communication
- **etcd**: Persistent storage for all cluster data
- **Scheduler**: Intelligent pod placement decisions
- **Controller Manager**: Maintains desired cluster state
- **Cloud Controller Manager**: Cloud-specific resource management

#### Data Plane Components:

- **Kubelet**: Node agent managing pod lifecycle
- **Kube-proxy**: Network proxy for service communication
- **Container Runtime**: Executes and manages containers
- **Pods**: Smallest deployable units containing containers
  stopped at the 1:00:14 mark

### Installing Kubernetes Locally with Minikube:
   - Minikube is a command line tool that allows you to run a **single-node Kubernetes cluster** on your local machine. It is a great way to learn and experiment with Kubernetes without needing a full-blown cluster.
#### We will be using docker desktop as the driver. Follow the steps below to install docker desktop and minikube.
1. **Install Docker Desktop**:
   - Download and install Docker Desktop from the [official Docker website](https://www.docker.com/products/docker-desktop).
   - Follow the installation instructions for your operating system (Windows, macOS, or Linux).
   - Once installed, ensure Docker Desktop is running and properly configured.
2. **Install Minikube**:
   - Follow the instructions on the [Minikube installation page](https://minikube.sigs.k8s.io/docs/start/) to install Minikube on your local machine.
3. **Start Minikube**:
   - Open a terminal and run the command:
     ```bash
        minikube start --driver=docker
     ```
4. **Stop Minikube**:
   - To stop the Minikube cluster, run the command:
     ```bash
        minikube stop
     ```
5. **Verify Installation**:
   - After starting Minikube, you can verify that your Kubernetes cluster is running by executing:
     ```bash
        kubectl get nodes
     ```
   - This command should display the status of the nodes in your Minikube cluster.
6. **Terminate Minikube**:
   - If you want to completely remove the Minikube cluster, you can run:
     ```bash
        minikube delete
     ```
### Deploying your first application on Minikube:
 - In kubernetes the lowest level of deployment is a pod. A pod can have one or more containers inside it. To deploy an application, we first create a pod using a yaml file. Here is an example yaml file to create a pod with a single nginx container.
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-pod
spec:
  containers:
  - name: nginx
    image: nginx:latest
    ports:
    - containerPort: 80
 Why cant you deploy the app as a container:
   - A pod is a definition of how to run a container. It provides additional features such as networking, storage, and resource management that are not available when running a container directly. Pods also allow for better scalability and management of containerized applications in a Kubernetes environment. All kubernetes deployments are done through yaml,files and are declarative in nature. The pod typically runs one container but there are scenarios where multiple containers are needed inside a pod. Putting a group of containers in a single pod will use shared networking, shared storage between the 2 containers. Kubernetes allocates a cluster ip address to the pod and not the container. Hence all containers inside a pod share the same ip address and port space. kube proxy is the component that generates the clouster ip address for the pod.
   - With kind you can create hundreds of clusters very easily. Kind uses docker containers as nodes. Hence you need to have docker installed on your machine to use kind.
   - To install kind follow the instructions on the official kind website: https://kind.sigs.k8s.io/docs/user/quick-start/
#### Installing your first pod:
1. Save the above yaml file as `nginx-pod.yaml`.
2. Open a terminal and navigate to the directory where the `nginx-pod.yaml` file is saved.
3. Run the following command to create the pod:
   ```bash
   kubectl apply -f nginx-pod.yaml or kubectl create -f nginx-pod.yaml
   ```
4. Verify that the pod is running by executing:
   ```bash
   kubectl get pods or kubectl get pods -o wide
   ```
5. You should see the `nginx-pod` listed with a status of `Running`.
6. To access the Nginx pod, you can use the following command:
   ```bash
   kubectl port-forward nginx-pod 8080:80
   ```
   This command will forward port 8080 on your local machine to port 80 on the Nginx pod.
7. Accessing the Nginx Pod:
   ```bash
   curl http://localhost:8080
   ```
8. You should see the default Nginx welcome page.
9. To login to the Nginx pod and explore its file system, run:
   ```bash
   kubectl exec -it nginx-pod -- /bin/bash
   ```
10. Minikube ssh command:
   - You can also ssh into the minikube node using the command:
   ```bash
   minikube ssh
   ```
   - This will give you access to the minikube virtual machine where you can explore the Kubernetes components and configurations.
- The pod.yaml file is a specification of how your docker container should run inside a pod. You can specify various parameters such as resource limits, environment variables, volume mounts, and more in the pod.yaml file to customize the behavior of your container within the pod.
11. To vierw the logs of the nginx pod, run:
   ```bash
   kubectl logs nginx-pod
   ```
12. You can also use the `kubectl describe` command to get detailed information about the pod:
   ```bash
   kubectl describe pod nginx-pod
   ```
### Managing autoscaling and autohealing with Kubernetes
 - Kubernetes provides built-in support for autoscaling and autohealing of applications running in pods. Autoscaling allows you to automatically adjust the number of pod replicas based on resource utilization or custom metrics, while autohealing ensures that failed pods are automatically replaced to maintain the desired state of the application.
 - Kubernetes uses **deployments** to manage the lifecycle of pods. A deployment is a higher-level abstraction that defines the desired state of a set of pods and provides features such as rolling updates, scaling, and self-healing. The deployment acts as a wrapper around the pod definition and provides additional functionality for managing the pods. 
#### Kubernetes Deployments: 
- What is the difference between a container a pod and a deployment?
   - A **container** is a lightweight, standalone executable package that includes everything needed to run a piece of software, including the code, runtime, libraries, and system tools. Containers are isolated from each other and the host system, allowing for consistent and reproducible environments.
   - A **pod** is the smallest deployable unit in Kubernetes and represents a single instance of a running process in a cluster. A pod can contain one or more containers that share the same network namespace and storage volumes. Pods are ephemeral and can be created, destroyed, and recreated as needed. Pods are not capable of autoscaling or self-healing on their own.
   - A **deployment** is a higher-level abstraction in Kubernetes that manages a set of pods. It defines the desired state of the application, including the number of replicas (pods) to run, the container image to use, and other configuration details. Deployments provide features such as rolling updates, scaling, and self-healing to ensure that the application remains available and responsive. Kubernetes suggest not to create opds directly but do it through deployments., Deployments create replica sets which in turn create pods.  replica sets ensure that the desired number of pod replicas are always running. This is how apps achieve zero downtime and high availability. Replica sets are kubernetes controllers that monitor the state of pods and ensure that the desired number of replicas are always running. If a pod fails or is deleted, the replica set will automatically create a new pod to replace it.
   - Here is an example yaml file to create a deployment with 3 replicas of an nginx container.
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:latest
        ports:
        - containerPort: 80
```
 - Save the above yaml file as `nginx-deployment.yaml`.
 - Open a terminal and navigate to the directory where the `nginx-deployment.yaml` file is saved.
 - Run the following command to create the deployment:
   ```bash
   kubectl apply -f nginx-deployment.yaml or kubectl create -f nginx-deployment.yaml
   ```
 - Verify that the deployment is running by executing:
   ```bash
   kubectl get deployments
   ```
 - You should see the `nginx-deployment` listed with 3 replicas.
 - To view the pods created by the deployment, run:
   ```bash
   kubectl get pods
   ```
 - You should see 3 pods with names starting with `nginx-deployment-`.
 - To scale the deployment up or down, you can use the following command:
   ```bash
   kubectl scale deployment nginx-deployment --replicas=5
   ```
 - This command will scale the deployment to 5 replicas. You can verify the scaling by running `kubectl get deployments` again.
 - To delete the deployment and all its associated pods, run:
   ```bash
   kubectl delete deployment nginx-deployment
   ```
- To view the number of replica sets, run:
   ```bash
   kubectl get replicasets or kubectl get rs
   ```
### Kubernetes Services:
 - In Kubernetes, a service is an abstraction that defines a logical set of pods and a policy by which to access them. Services provide a stable IP address and DNS name for a set of pods, allowing other components in the cluster to communicate with them without needing to know their individual IP addresses.
 - There are several types of services in Kubernetes, including ClusterIP, NodePort, LoadBalancer, and ExternalName. Each type of service has its own use case and configuration options.
 - Here is an example yaml file to create a ClusterIP service for the nginx deployment we created earlier.
```yaml