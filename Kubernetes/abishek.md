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

#### We will be using docker desktop as the driver. Follow the steps below to install docketr desktop and minikube.

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

