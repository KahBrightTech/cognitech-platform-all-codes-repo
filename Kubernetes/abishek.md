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

- **API Server**: The API server is the front-end of the Kubernetes control plane. It exposes the Kubernetes API and serves as the main entry point for all administrative tasks. It processes RESTful requests, validates them, and updates the corresponding objects in the etcd datastore. This exposes kubernetes to the external world
- **etcd**: etcd is a distributed key-value store that serves as the backing store for all cluster data. It stores the configuration data, state information, and metadata about the cluster and its resources.
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
   - A pod is a definition of how to run a container. It provides additional features such as networking, storage, and resource management that are not available when running a container directly. Pods also allow for better scalability and management of containerized applications in a Kubernetes environment. All kubernetes deployments are done through yaml,files and are declarative in nature. The pod typically runs one container but there are scenarios where multiple containers are needed inside a pod. Putting a group of containers in a single pod will use shared networking, shared storage between the 2 containers. Kubernetes allocates a cluster ip address to the pod and not the container. Hence all containers inside a pod share the same ip address and pod space. kube proxy is the component that generates the cluster ip address for the pod.
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
  - A **deployment** is a higher-level abstraction in Kubernetes that manages a set of pods. It defines the desired state of the application, including the number of replicas (pods) to run, the container image to use, and other configuration details. Deployments provide features such as rolling updates, scaling, and self-healing to ensure that the application remains available and responsive. Kubernetes suggest not to create pods directly but do it through deployments., Deployments create replica sets which in turn create pods.  Replica sets ensure that the desired number of pod replicas are always running. This is how apps achieve zero downtime and high availability. Replica sets are kubernetes controllers that monitor the state of pods and ensure that the desired number of replicas are always running. If a pod fails or is deleted, the replica set will automatically create a new pod to replace it.
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

- This is a critical concept in kubernetes. For each deployment is kubernetes you create a service. 
#### What is the importance of services in kubernetes?
##### Without services:
- The ideal pods count is contingent on the number of users trying to access the pods and the number of connections each pod can handle. A pod going down is not an issue in kubernetes due to the autohealing capability. When a pod comes up it has a new ip address so in a scenario without services you will have to provide the new ip address to users trying to access the pod. This is not feasible in a production environment. 
##### With services:
- Services provide a **stable endpoint (IP address and DNS name)** for accessing a set of pods, regardless of their individual IP addresses. 
- Services also provide load balancing, distributing incoming traffic across multiple pod instances to ensure high availability and optimal resource utilization.
- Service discovery. The service keeps track of pods that match its label selector and automatically updates its endpoints as pods are added or removed. This allows clients to discover and connect to the appropriate pods without needing to know their individual IP addresses.
- Service can also expose the application to external traffic using different service types such as **NodePort**, **LoadBalancer**, and **ClusterIP**.

### 📊 Kubernetes Service Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                                KUBERNETES CLUSTER                               │
│                                                                                 │
│  ┌─────────────────────────────────────────────────────────────────────────┐    │
│  │                              NAMESPACE                                  │    │
│  │                                                                         │    │
│  │   ┌─────────────────┐                                                  │    │
│  │   │     CLIENT      │                                                  │    │
│  │   │   (External)    │                                                  │    │
│  │   └─────────┬───────┘                                                  │    │
│  │             │                                                          │    │
│  │             │ HTTP Request                                             │    │
│  │             │ (Port 80)                                                │    │
│  │             ▼                                                          │    │
│  │   ┌─────────────────┐                                                  │    │
│  │   │    SERVICE      │                                                  │    │
│  │   │  (ClusterIP)    │                                                  │    │
│  │   │                 │                                                  │    │
│  │   │ Name: web-svc   │                                                  │    │
│  │   │ Port: 80        │                                                  │    │
│  │   │ TargetPort: 8080│                                                  │    │
│  │   │ Selector:       │                                                  │    │
│  │   │   app: web      │                                                  │    │
│  │   └─────────┬───────┘                                                  │    │
│  │             │                                                          │    │
│  │             │ Load Balancing                                           │    │
│  │             │                                                          │    │
│  │   ┌─────────┼─────────────────────────────────────────┐               │    │
│  │   │         │              ENDPOINTS                  │               │    │
│  │   │         │                                         │               │    │
│  │   │         ▼                                         │               │    │
│  │   │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐│               │    │
│  │   │  │    POD 1    │  │    POD 2    │  │    POD 3    ││               │    │
│  │   │  │             │  │             │  │             ││               │    │
│  │   │  │ IP: 10.1.1.2│  │ IP: 10.1.1.3│  │ IP: 10.1.1.4││               │    │
│  │   │  │ Port: 8080  │  │ Port: 8080  │  │ Port: 8080  ││               │    │
│  │   │  │ Labels:     │  │ Labels:     │  │ Labels:     ││               │    │
│  │   │  │   app: web  │  │   app: web  │  │   app: web  ││               │    │
│  │   │  │             │  │             │  │             ││               │    │
│  │   │  │ ┌─────────┐ │  │ ┌─────────┐ │  │ ┌─────────┐ ││               │    │
│  │   │  │ │Container│ │  │ │Container│ │  │ │Container│ ││               │    │
│  │   │  │ │ nginx   │ │  │ │ nginx   │ │  │ │ nginx   │ ││               │    │
│  │   │  │ │         │ │  │ │         │ │  │ │         │ ││               │    │
│  │   │  │ └─────────┘ │  │ └─────────┘ │  │ └─────────┘ ││               │    │
│  │   │  └─────────────┘  └─────────────┘  └─────────────┘│               │    │
│  │   └─────────────────────────────────────────────────────┘               │    │
│  └─────────────────────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────────────────────┘

```

#### How Kubernetes Service Works:

##### 1. **Service Discovery**
```
Service provides a stable endpoint:
- DNS Name: web-svc.default.svc.cluster.local
- Cluster IP: 10.96.1.100 (Virtual IP)
- Port: 80
```

##### 2. **Traffic Flow**
```
Client Request → Service (Port 80) → Load Balancer → Pod (Port 8080)
```

##### 3. **Label Selector Matching**
```yaml
# Service Definition
apiVersion: v1
kind: Service
metadata:
  name: web-svc
spec:
  selector:
    app: web        # Matches Pods with label app=web
  ports:
  - port: 80        # Service port
    targetPort: 8080 # Pod port
  type: ClusterIP
```

##### 4. **Service Types**
- **ClusterIP**: Internal access only. This only works within the cluster. Only benefits here are discovery and load balancing. Only people who have access to the cluster can access the app. This is the default service type.
- **NodePort**: External access via Node IP and port within the organization. Who has access to the nodes can access the service. Only people who have access to the nodes in the vpc can access the app. 
- **LoadBalancer**: External access via cloud provider load balancer. This allows access from outside the organization. You can access the app using a public IP address. This only works if you are running kubernetes on a cloud provider that supports load balancers. for instance amazon.com

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   ClusterIP     │    │    NodePort     │    │  LoadBalancer   │
│   (Internal)    │    │   (External)    │    │   (External)    │
│                 │    │                 │    │                 │
│ Only accessible│    │ Accessible via  │    │ Cloud provider  │
│ within cluster  │    │ Node IP:Port    │    │ load balancer   │
│                 │    │                 │    │                 │
│ Default type    │    │ Port range:     │    │ External IP     │
│                 │    │ 30000-32767     │    │ assigned        │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

##### 5. **Service Components**

```
┌─────────────────────────────────────────────────────────────────┐
│                        SERVICE                                  │
│                                                                 │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────────┐  │
│  │   SELECTOR  │  │  ENDPOINTS  │  │       PORTS             │  │
│  │             │  │             │  │                         │  │
│  │ app: web    │──│ 10.1.1.2:80 │  │ port: 80 (service)      │  │
│  │ tier: front │  │ 10.1.1.3:80 │  │ targetPort: 8080 (pod)  │  │
│  │             │  │ 10.1.1.4:80 │  │ protocol: TCP           │  │
│  └─────────────┘  └─────────────┘  └─────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

##### 6. **Load Balancing Algorithms**
- **Round Robin** (Default): Distributes requests evenly
- **Session Affinity**: Routes to same Pod based on client IP

#### Key Benefits of Services:
- **Service Discovery**: Stable DNS name and IP
- **Load Balancing**: Distributes traffic across healthy Pods
- **High Availability**: Continues working if Pods fail
- **Decoupling**: Pods can be replaced without affecting clients

##### Hands-on session for Kubernetes Services:
- First go to the github source code and clone it to your local. The repo is https://github.com/iam-veeramalla/Docker-Zero-to-hero
- In the demo hs used the python based application located at Kubernetes\Docker-Zero-to-Hero\examples\python-web-app
- We created the docker image using the docker build command. So docker build -t python-web-app:latest:v1 .
- Then we created a deployment.yaml file for the python app to be deployed. 
- The app could not be accessed externally because the default service type is cluster ip. running curl -L ip:8000/demo allowed us to access the app within the cluster only.
- To access the app within the organization we created a service.yaml file. 
- To create a new service after creating the service.yaml file run the command kubectl apply -f service.yaml
- To verify the service is created run the command kubectl get services
- The service type we first created was nodeport which was mapped to port 30007 on the node. So to access the app we ran curl -L <minikube ip>:30007/demo
- To access the minikube ip run the command minikube ip 
- The cluster ip mapped with the port is mapped to the node ip with the nodeport which was 30007 in our case.. So to access the application you can either do so from within the cluster using the cluster ip and port or from within the organization using the node ip and nodeport. Docker creates an isolated network for the containers. Hence you cannot access the nodeport directly from the host machine. To access the application from your local your can create a service tunnel with the following command:
  ```bash
     minikube service <service-name> --url
  ```
- This will create a tunnel between the host machine and the minikube docker container. Now you can access the application using the url provided by the above command.
- The load balancer type here will not work as it has to be run on a cloud provider. This is done by the cloud controller manager component of the control plane.
- I was not able to access the nodeport using minikube cause it uses docker which is isolated and not accessed from the host. You need to create a tunnel to access the nodeport from the host machine. To create a tunnel run the command minikube tunnel in a separate terminal. This will create a tunnel between the host and the minikube docker container. Now you can access the nodeport using the minikube ip and nodeport.

### Namespaces in Kubernetes:
- Namespace in kubernetes is a logical isolation of resources, network, policies, rbac and everything else in a kubernetes cluster.
- Namespaces are a way to divide cluster resources between multiple users (via resource quota). They provide a scope for names. Names of resources need to be unique within a namespace, but not across namespaces. Namespaces are intended for use in environments with many users spread across multiple teams, or projects.
- You can use namespaces to create multiple virtual clusters within a single physical cluster. This allows you to isolate resources and manage access control for different teams or projects.
- To create a namespace, you can use the following command:
  ```bash
  kubectl create namespace <namespace-name>
  ```
- To view all namespaces in the cluster, you can use the command:
  ```bash 
  kubectl get namespaces
  ```
- To deploy resources in a specific namespace, you can use the `-n` or `--namespace` flag with the `kubectl` command. For example:
  ```bash
  kubectl apply -f <resource-file.yaml> -n <namespace-name>
  ```

### Ingress in Kubernetes:
#### What is ingress? 
- The service offered the following benefits:
    - Service discovery
    - Load balancing
    - Expose traffic to the outside world
- However clients coming from legacy systems using enterprise load balancers noticed some limitation on the service offered by kubernetes.

#### Limitations of Services:
- The service only provides simple round robin load balancing which was limited unlike enterprise load balancers which offered advanced features such as SSL termination, sticky session, Path based load balancing, URL routing, and more.
- Service of type load balancer was expensive as the cloud provider was charging the client for each service of type load balancer created.

#### To overcome these limitations kubernetes introduced ingress.
- To overcome this Red Hat implemented OpenShift to address these limitations.
- The folks from google created an ingress controller called **GLBC** (Google Load Balancer Controller) to address these limitations.
- Later on other ingress controllers were created such as **NGINX Ingress Controller**, **Traefik Ingress Controller**, **HAProxy Ingress Controller** etc.,
- The ingress controller gives you all the features of an enterprise load balancer such as SSL termination, sticky session, Path based load balancing, URL routing, and more.
- **The user creates the ingress resource and the load balancing companies like nginx or F5 writes their own ingress controllers and place them in github and provides instructions on how to use their ingress controllers. The organization can choose any ingress controller they want based on their requirements**.
- So if you used to use nginx load balancers in your legacy systems you can use the nginx ingress controller in kubernetes based on instructions provided by nginx.
- The ingress resource is typically written once which is able to handle hundreds of services running in the kubernetes cluster. This reduces the cost of using multiple load balancers for each service.

#### Hands on session for Kubernetes Ingress:
- To create an ingress fisrt go to the kubernetes officiakl documentation and choose an ingress controller based on your requirements.
- Go to https://kubernetes.io/docs/concepts/services-networking/ingress/
- Create an ingress.yaml file as shown below:
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: cognilife
spec:
  rules:
  - host: "cognilife.com"
  - http:
      paths:
      - pathType: Prefix
        path: "/save"
        backend:
          service:
            name: cognilife
            port:
              number: 80
```
- Now deploy the file using the command:
  ```bash
     kubectl apply -f ingress.yaml
  ```
- To verify the ingress is created run the command:
  ```bash
     kubectl get ingress
  ```
- This will still not work because we havent created the ingress controller yet.
- To create the ingress controller follow the instructions provided by the ingress controller of your choice.
- Go to https://kubernetes.io/docs/concepts/services-networking/ingress-controllers/ and follow the instructions provided there to create the ingress controller of your choice.
- From here we will use the nginx ingress controller.
- Follow the instructions provided here to create the nginx ingress controller: https://kubernetes.io/docs/tasks/access-application-cluster/ingress-minikube/
- Once the ingress controller is created you can access your services using the ingress resource you created earlier.
- The command to enable the ingress controller in minikube is:
  ```bash
     minikube addons enable ingress
  ```
- To verify the ingress controller is created run the command:
  ```bash
     kubectl get pods -n ingress-nginx
  ```
- The ingress ciontroller is also a pod and shows up as 
```
ingress-nginx-admission-create-5fb8b       0/1     Completed   0          98s
ingress-nginx-admission-patch-vt77n        0/1     Completed   1          98s
ingress-nginx-controller-9cc49f96f-nnn4r   1/1     Running     0          98s
```
- Since I dont have a domain on my local I first got the ingress co ntrollers ip using the command:
  ```bash
     kubectl get ingress
  ```
- Then I added an entry in the hosts file of my local machine to map the domain cognilife.com to the ingress controller ip.
- Now I was able to access the service using the domain name cognilife.com/save

### ConfigMaps and Secrets in Kubernetes:
#### What is a ConfigMap? Non sensitive data storage
- Think about an application trying to get some configuration data from a database or a file. This configuration data can be anything such as database connection strings, API keys, feature flags, environment variables, etc.,
- In kubernetes we have a special resource called ConfigMap to store such configuration data.
- The configmap is created in a kubernetes cluster. The information is stored in the configmap and used by the application running in the pod.
- The configmap can be created using a yaml file or using the kubectl command line tool
- As a devops engineer you will be creating configmaps to store configuration data for the applications running in the kubernetes cluster.
- Storing sensitive data in configmaps makes it vulnerable to hackers as they can get the information from either the configmap file by running **kubectl describe configmap <configmap-name>** or by accessing the etcd database directly since its not encrypted.
#### Creating a ConfigMap using a yaml file:
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
data:
  DATABASE_URL: "mongodb://mongo:27017/mydb"
  FEATURE_FLAG: "true"  
  API_KEY: "12345-abcde-67890-fghij"
```
- Save the above yaml file as configmap.yaml
- To create the configmap run the command:
  ```bash
     kubectl apply -f configmap.yaml
  ```
- To verify the configmap is created run the command:
  ```bash
     kubectl get configmaps
  ```
- To edit the configmap run the command:
  ```bash
     kubectl edit configmap configmap-name ex : kubectl edit configmap app-config
  ```
  #### Why do we need secrets in kubernetes? Sensitive data storage
  - Secrets in kubernetes are used to store sensitive information such as passwords, OAuth tokens, ssh keys, etc.,
  - Storing such sensitive information in plain text in configmaps or environment variables is not secure
  - Secrets provide a way to store such sensitive information securely in the kubernetes cluster
  - **Secrets are stored in etcd in an encoded format (base64 encoded) which is more secure than plain text**
  - For secrets the data is encrypted at thge level of etcd. So even if a hacker gains access to the etcd database they will not be able to read the secrets as they are encrypted.
  - As for the yaml file it is recommended to use a strong RBAC policy to restrict access to the yaml files containing secrets. Only authorized personnel should have access to such files.
#### Creating a Secret using a yaml file:
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: app-secret
type: Opaque
data:
  DB_PASSWORD: cGFzc3dvcmQxMjM=   # base64 encoded value of 'password123
  API_TOKEN: YWJjZGVmZ2hpamtsbW5vcHFyc3R1dnd4eXo=  # base64 encoded value of 'abcdefghijklmnopqrstuvwxyz'
```
- Save the above yaml file as secret.yaml
- To create the secret run the command:
  ```bash
     kubectl apply -f secret.yaml
  ```
- To verify the secret is created run the command:
  ```bash
     kubectl get secrets
  ```
#### Hands-on session for ConfigMaps and Secrets:
- After creating the configmap using the above command you can use the configmap in your pod in the following ways:
  - As environment variables
  - As command line arguments
  - As configuration files in a volume
- To use the configmap as environment variables in a pod, you can use the following yaml file:
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: app-pod
spec:
  containers:
  - name: app-container
    image: my-app:latest
    envFrom:
    - configMapRef:
        name: app-config
```
- This can also be used in our deployments. Similarly secrets can also be used as environment variables in a pod or deployment. To use a configmap in a deployemhent you can use the following yaml file:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app-deployment
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
      - name: app-container
        image: my-app:latest
        env:
        - name: DB-PORT
          valueFrom:
            configMapKeyRef:
              name: app-config
              key: db-port
        - name: DB-HOST
          valueFrom:
            configMapKeyRef:
              name: app-config
              key: db-host
        - name: DB-USER
          valueFrom:
            configMapKeyRef:
              name: app-config
              key: db-user
        - name: DB-PASSWORD
          valueFrom:
            secretKeyRef:
              name: app-secret
              key: db-password
```
- In the above deployment yaml file we are using both configmap and secret to store database connection
- The configmap needs to be created first before creating the deployment. The secret also needs to be created before creating the deployment.
- You can login to the pod and verify the environment variables are set using the command:
  ```bash
     kubectl exec -it app-pod -- /bin/bash
  ```
- Then run the command:
  ```bash
     env | grep DB
  ```
- This will show the environment variables set in the pod.
- what if I want to update the environment variables in the pods using the configmap? This cannot be done in the container directly. 
- Kubernetes suggest to use VolumeMounts to update any changing variables. So instead of configmap use VolumeMounts to mount the configmap as a file in the pod. Whenever the configmap is updated the file in the pod will also be updated. The application can read the file and get the updated values. This way we can avoid restarting the pod to get the updated values.
- To create a volume mount you update the yaml file to add the volumes as shown below:
```yaml 
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app-deployment
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
      - name: app-container
        image: my-app:latest
        volumeMounts:
        - name: config-volume
          mountPath: /opt
      volumes:
      - name: config-volume
        configMap:
          name: app-config
```
- In the above yaml file we are mounting the configmap as a file in the pod at /opt
- This will automatically update the file in the pod whenever the configmap is updated.
- To update the configmap you can use the following command:
  ```bash
     kubectl edit configmap app-config
  ```
- To verify the configmap is created run the command:
  ```bash
     kubectl get configmaps
  ```
- Once the configmap get updated with new values the pods automatically gets updated as these are mounted volumes which does not require restarted or destroying the pod.
- There is a little bit of delay in updating the configmap values in the pod. It takes around 1 minute to update the values in the pod.
- Similarly secrets can also be mounted as volumes in the pod. The process is same as configmaps.
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app-deployment
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
      - name: app-container
        image: my-app:latest
        volumeMounts:
        - name: secret-volume
          mountPath: /etc/secret
      volumes:
      - name: secret-volume
        secret:
          secretName: app-secret  
