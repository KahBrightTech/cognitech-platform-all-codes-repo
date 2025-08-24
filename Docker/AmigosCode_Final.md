# 🐳 Docker Tutorial - Complete Professional Guide

> A comprehensive guide to Docker containerization technology, covering everything from basic concepts to advanced usage patterns.

## 📋 Table of Contents

- [🐳 Docker Tutorial - Complete Professional Guide](#-docker-tutorial---complete-professional-guide)
  - [📋 Table of Contents](#-table-of-contents)
  - [🚀 What is Docker?](#-what-is-docker)
  - [⚖️ Container vs VM](#️-container-vs-vm)
  - [✨ Benefits of Using Docker](#-benefits-of-using-docker)
  - [💻 Installing Docker](#-installing-docker)
  - [📦 Docker Images and Containers](#-docker-images-and-containers)
  - [🔄 Working with Images](#-working-with-images)
  - [🏃 Running Containers](#-running-containers)
  - [🌐 Port Management](#-port-management)
  - [🛠️ Container Management](#️-container-management)
  - [📊 Docker PS and Formatting](#-docker-ps-and-formatting)
  - [💾 Docker Volumes](#-docker-volumes)
  - [📝 Dockerfile Basics](#-dockerfile-basics)
  - [⚡ Node.js and Docker](#-nodejs-and-docker)
  - [🎯 Docker Best Practices](#-docker-best-practices)
  - [🏪 Docker Registries](#-docker-registries)
  - [🔧 Advanced Commands](#-advanced-commands)
  - [🩺 Troubleshooting Tips](#-troubleshooting-tips)
  - [📚 Summary](#-summary)
  - [🔗 Additional Resources](#-additional-resources)

---

## 🚀 What is Docker?

Docker is a revolutionary containerization platform that transforms how we deploy and manage applications:

- **🏠 Isolated Environments**: Run applications in containerized environments similar to VMs but more efficient
- **🔄 Environment Consistency**: Guaranteed consistency—if it works in staging, it works in production
- **📦 Deployment Standard**: Industry-standard tool for packaging and deploying applications
- **🌍 Universal Adoption**: Adopted by companies worldwide for modern cloud-native deployments

---

## ⚖️ Container vs VM

### 🐳 **Containers**
| Feature | Description |
|---------|-------------|
| **Abstraction Level** | App layer - packages code and dependencies |
| **OS Sharing** | Share host OS kernel with other containers |
| **Process Isolation** | Run as isolated processes in user space |
| **Resource Usage** | Lightweight - no full OS required |
| **Startup Time** | Seconds |

### 💻 **Virtual Machines**
| Feature | Description |
|---------|-------------|
| **Abstraction Level** | Hardware layer - turns one server into many |
| **OS Requirements** | Each VM includes full OS copy |
| **Resource Usage** | Heavy - requires full OS, binaries, libraries |
| **Storage** | Tens of GBs per VM |
| **Startup Time** | Minutes |

---

## ✨ Benefits of Using Docker

| Benefit | Impact |
|---------|--------|
| ⚡ **Speed** | Containers start in seconds vs minutes for VMs |
| 💿 **Storage** | Reduced disk space requirements |
| 🧠 **Memory** | Lower memory footprint |
| 🎯 **Consistency** | Simplified deployment and testing |
| 📈 **Scalability** | Easy horizontal scaling |

---

## 💻 Installing Docker

### 📖 Method 1: Official Documentation
Visit the [Docker Installation Guide](https://docs.docker.com/install) for platform-specific instructions.

### 🐧 Method 2: Amazon Linux 2023
```bash
# Install Docker
sudo dnf install docker -y

# Start Docker service
sudo systemctl start docker

# Enable Docker to start on boot
sudo systemctl enable docker

# Add current user to docker group (optional)
sudo usermod -aG docker $USER
```

### 🪟 Method 3: Docker Desktop (Windows)
1. **Download** Docker Desktop from [Docker Hub](https://hub.docker.com)
2. **Install WSL2** (Windows Subsystem for Linux 2)
3. **Run Docker Desktop** and ensure it starts properly
4. **Verify** Docker daemon is running

> ⚠️ **Critical**: Always ensure the Docker daemon is running before executing commands!

---

## 📦 Docker Images and Containers

### 🖼️ **Understanding Images**
- **📋 Template**: Blueprint for creating consistent environments
- **📸 Snapshot**: Versioned captures of your application state
- **📦 Complete Package**: Contains everything your app needs to run

### 🏃 **Understanding Containers**
- **▶️ Running Instance**: Active execution of an image
- **🔄 Stateful**: Can be started, stopped, and restarted
- **🗂️ Isolated**: Each container runs independently

### 📊 **Example Image Listing**
```bash
REPOSITORY   TAG       IMAGE ID       CREATED      SIZE
nginx        latest    33e0bbc7ca9e   2 days ago   279MB
httpd        latest    3198c1839e1a   7 days ago   174MB
redis        7-alpine  abc123def456   1 week ago   32MB
```

### 🏷️ **Understanding Tags**
- **🔖 Version Control**: Specify exact image versions (e.g., `nginx:1.21`, `node:16-alpine`)
- **📌 Default Behavior**: Docker uses `latest` tag when none specified
- **🎯 Production Rule**: Always use explicit tags in production to avoid surprises

---

## 🔄 Working with Images

### 📥 **Pulling Docker Images**

#### 🌐 Docker Hub Workflow
1. **Visit**: Navigate to [Docker Hub](https://hub.docker.com)
2. **Search**: Find the images you need
3. **Login**: Use your Docker credentials
4. **Explore**: Check available tags and documentation

#### 📥 Pull Commands
```bash
# Pull latest version
docker pull nginx

# Pull specific version
docker pull nginx:1.21-alpine

# Pull multiple images
docker pull nginx redis postgres:13
```

#### 📋 View Local Images
```bash
# List all images
docker images

# List specific repository
docker images nginx

# Show image sizes
docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"
```

---

## 🏃 Running Containers

### 🚀 **Basic Container Operations**

```bash
# Run container (interactive mode)
docker run nginx:latest

# Run in detached mode (background)
docker run -d nginx:latest

# Run with custom name
docker run -d --name web-server nginx:latest

# Run and remove after exit
docker run --rm nginx:latest
```

### 🔄 **Container Lifecycle Management**

```bash
# Stop a running container
docker stop web-server

# Start a stopped container
docker start web-server

# Restart a container
docker restart web-server

# Pause/unpause container
docker pause web-server
docker unpause web-server
```

### 👀 **Monitoring Containers**

```bash
# List running containers
docker ps

# List all containers (including stopped)
docker ps -a

# Show container resource usage
docker stats

# Show container processes
docker top web-server
```

---

## 🌐 Port Management

### 🔌 **Port Mapping Basics**

Docker containers run in isolated networks. To access services, you need to map ports:

```bash
# Map single port: host:container
docker run -d -p 8080:80 nginx

# Map multiple ports
docker run -d -p 8080:80 -p 8443:443 nginx

# Map to all interfaces
docker run -d -p 0.0.0.0:8080:80 nginx

# Let Docker choose host port
docker run -d -P nginx  # Publishes all exposed ports
```

### 🏷️ **Named Containers with Ports**

```bash
# Create named container with port mapping
docker run -d --name my-website -p 8080:80 nginx

# Access your application
curl http://localhost:8080
```

### 🌍 **Multiple Port Examples**

```bash
# Web application with database
docker run -d --name webapp -p 3000:3000 node:latest
docker run -d --name database -p 5432:5432 postgres:13

# Load balancer setup
docker run -d --name lb -p 80:80 -p 443:443 nginx
```

> 💡 **Best Practice**: Always use meaningful container names for easier management!

---

## 🛠️ Container Management

### 🗑️ **Cleanup Operations**

```bash
# Remove a stopped container
docker rm container-name

# Force remove a running container
docker rm -f container-name

# Remove all stopped containers
docker container prune

# Remove containers older than 24h
docker container prune --filter "until=24h"
```

### 🖼️ **Image Management**

```bash
# Remove an image
docker rmi image-name

# Remove unused images
docker image prune

# Remove all images
docker rmi $(docker images -q)

# Show image layers
docker history nginx:latest
```

### 🧹 **System Cleanup**

```bash
# Remove everything not in use
docker system prune

# Aggressive cleanup (removes all stopped containers, unused images, networks, build cache)
docker system prune -a

# Check disk usage
docker system df
```

---

## 📊 Docker PS and Formatting

### 📋 **Standard Listing Commands**

```bash
# Show running containers
docker ps

# Show all containers
docker ps -a

# Show only container IDs
docker ps -q

# Show latest created container
docker ps -l
```

### 🎨 **Custom Output Formatting**

Docker provides powerful formatting options for better readability:

```bash
# Table format with selected columns
docker ps --format "table {{.ID}}\t{{.Image}}\t{{.Status}}\t{{.Names}}"

# Custom format with labels
docker ps --format "{{.Names}} -> {{.Status}} ({{.Image}})"

# JSON output for automation
docker ps --format "{{json .}}"
```

### 📊 **Available Format Fields**

| Field | Description | Example |
|-------|-------------|---------|
| `{{.ID}}` | Container ID | `abc123def456` |
| `{{.Image}}` | Image name | `nginx:latest` |
| `{{.Command}}` | Start command | `nginx -g daemon off` |
| `{{.CreatedAt}}` | Creation time | `2023-01-15 10:30:45` |
| `{{.Status}}` | Current status | `Up 2 hours` |
| `{{.Ports}}` | Port mappings | `0.0.0.0:8080->80/tcp` |
| `{{.Names}}` | Container name | `web-server` |
| `{{.Size}}` | Container size | `1.2MB` |

### 🔍 **Filtering Results**

```bash
# Show only exited containers
docker ps -a --filter "status=exited"

# Show containers by name pattern
docker ps --filter "name=web*"

# Show containers by image
docker ps --filter "ancestor=nginx"

# Combine filters
docker ps -a --filter "status=exited" --filter "name=test*"
```

### ⚡ **Creating Useful Aliases**

Add these to your `~/.bashrc` or `~/.zshrc`:

```bash
# Quick container listing
alias dps='docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}"'
alias dpsa='docker ps -a --format "table {{.Names}}\t{{.Image}}\t{{.Status}}"'

# Show resource usage
alias dstats='docker stats --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}"'

# Quick cleanup
alias dclean='docker system prune -f'
```

### 🌍 **Environment Variables for Formatting**

```bash
# In WSL/bash, create a variable for the format string:
DOCKER_FORMAT="table {{.ID}}\t{{.Image}}\t{{.Command}}\t{{.CreatedAt}}\t{{.Status}}\t{{.Ports}}\t{{.Names}}"

# Then use it:
docker ps --format "$DOCKER_FORMAT"

# To make it permanent, add to ~/.bashrc:
export DOCKER_FORMAT="table {{.ID}}\t{{.Image}}\t{{.Command}}\t{{.CreatedAt}}\t{{.Status}}\t{{.Ports}}\t{{.Names}}"

# Or create aliases for easier use:
alias dps='docker ps --format "table {{.ID}}\t{{.Image}}\t{{.Command}}\t{{.CreatedAt}}\t{{.Status}}\t{{.Ports}}\t{{.Names}}"'
alias dpsa='docker ps -a --format "table {{.ID}}\t{{.Image}}\t{{.Command}}\t{{.CreatedAt}}\t{{.Status}}\t{{.Ports}}\t{{.Names}}"'
```

---

## 💾 Docker Volumes

### 🗄️ **What are Docker Volumes?**

Volumes solve the problem of data persistence in containers:

- **📁 Persistent Storage**: Data survives container restarts and removals
- **🌍 External Storage**: Stored outside container filesystem
- **🤝 Shareable**: Can be mounted to multiple containers
- **🛡️ Managed by Docker**: Stored in `/var/lib/docker/volumes/` on Linux

### 🔧 **Volume Operations**

```bash
# Create a named volume
docker volume create my-data

# List all volumes
docker volume ls

# Inspect volume details
docker volume inspect my-data

# Remove unused volumes
docker volume prune

# Remove specific volume
docker volume rm my-data
```

### 📂 **Using Volumes in Containers**

```bash
# Mount named volume
docker run -v my-data:/app/data nginx

# Alternative mount syntax
docker run --mount source=my-data,target=/app/data nginx

# Mount host directory (bind mount)
docker run -v /host/path:/container/path nginx

# Mount current directory
docker run -v $(pwd):/app nginx
```

### 🌐 **Web Development Example**

```bash
# Create a folder called website and have a file called index.html in it
# Command is:
docker run --name website -v $(pwd)/website:/usr/share/nginx/html -d nginx

# Where pwd is the current working directory and website is the folder that contains the index.html file.

# To point to the index.html file in the host from WSL, you can use the following path:
# /mnt/c/Users/Owner/Downloads/GitRepos/cognitech-repos/cognitech-platform-all-codes-repo/Docker/website/index.html

# If the index.html file is found in the present working directory you do not need to specify the full path
# You can also use the relative path like this:
# ./website/index.html

# You can simply use $(pwd) to get the current working directory and not have to specify the index.html file path.

# If there are multiple index.html files in the present working directory you can use the following command:
docker run --name website -v $(pwd)/index.html:/usr/share/nginx/html/index.html -d nginx

# This will mount the specific index.html file into the container, allowing you to work with that file directly.

# Read-only mount
docker run -d --name website \
  -p 8080:80 \
  -v $(pwd)/website:/usr/share/nginx/html:ro \
  nginx

# The command docker exec website ls -la /usr/share/nginx/html shows you the contents of the /usr/share/nginx/html directory inside the container, which is where the index.html file is mounted.

# Docker exec -it name of container bash eg docker exec -it website bash. This command allows you to access the container's shell.
```

### 🔗 **Sharing Volumes Between Containers**

```bash
# Create first container with volume
docker run -d --name data-container -v shared-data:/data alpine

# Share volume with another container using --volumes-from
docker run -d --name app-container --volumes-from data-container nginx

# The --volumes-from option allows you to share volumes between containers. This means that the app-container will have access to the same volumes as the data-container.

# Multiple containers sharing the same volume
docker run -d --name web1 -v shared-content:/usr/share/nginx/html nginx
docker run -d --name web2 -v shared-content:/usr/share/nginx/html nginx

# Example sharing volumes between containers:
docker run --name kali -d -p 8082:80 --volumes-from kah nginx:latest
```

### 🎨 **Customize Website**

```bash
# To customize your website you can go to this website and get free templates for testing 
# https://startbootstrap.com/themes/landing-pages
# Download the template and extract it to the websites folder
# This might not work if the directory does not have an index.html file
# You can also create a simple index.html file in the websites folder with the following content
```

### 💡 **Volume Best Practices**

- **🏷️ Name your volumes**: Use descriptive names like `postgres-data` or `app-logs`
- **🗑️ Regular cleanup**: Remove unused volumes with `docker volume prune`
- **💾 Backup important data**: Volumes can be backed up using `docker run --volumes-from`
- **🔒 Consider permissions**: Ensure proper file permissions for mounted directories

---

## 📝 Dockerfile Basics

### 📋 **What is a Dockerfile?**

A Dockerfile is your blueprint for creating custom Docker images:

- **📄 Text File**: Contains instructions to build an image
- **🏗️ Layer-based**: Each instruction creates a new image layer
- **🔁 Reproducible**: Same Dockerfile = Same image every time
- **📦 Self-contained**: Defines everything needed to run your application
- **🔑 FROM keyword required**: Every Dockerfile must have the FROM keyword
- **📚 Documentation**: The following link provides more information: https://docs.docker.com/engine/reference/builder/
- **🔄 Series of steps**: Define how your image is built
- **🖼️ Base image**: Images should contain everything your application needs to run

### 🏗️ **Basic Dockerfile Structure**

```dockerfile
# Every Dockerfile starts with a base image
FROM nginx:latest

# The ADD instruction is used to copy files and directories from your host machine into the Docker image.
ADD . /usr/share/nginx/html
```

### 🔨 **Building Images**

```bash
# Build image with tag
docker build -t highway:latest .

# The `-t` flag allows you to tag the image with a name for easier reference.
# The `.` at the end specifies the build context, which is the current directory.

# Build with multiple tags
docker build -t highway:1.0 -t highway:latest .

# The resulting image can then be run using the command:
docker run -d -p 8080:80 highway:latest
# which starts a new container from the image and maps port 8080 on the host to port 80 in the container.
```

### 🎯 **Common Dockerfile Instructions**

| Instruction | Purpose | Example |
|-------------|---------|---------|
| `FROM` | Base image | `FROM node:16-alpine` |
| `WORKDIR` | Set working directory | `WORKDIR /app` |
| `COPY` | Copy files | `COPY . .` |
| `ADD` | Copy + extract | `ADD app.tar.gz /app` |
| `RUN` | Execute commands | `RUN npm install` |
| `CMD` | Default command | `CMD ["npm", "start"]` |
| `ENTRYPOINT` | Fixed command | `ENTRYPOINT ["python"]` |
| `EXPOSE` | Document ports | `EXPOSE 3000` |
| `ENV` | Set environment | `ENV NODE_ENV=production` |

---

## ⚡ Node.js and Docker

### 🚀 **Setting Up Node.js Development Environment**

#### 📦 Installing Node.js 
```bash
# Download Node.js on your local machine from https://nodejs.org/en/download/
# We will be using Node.js and Express to create our web application.
# Express is a web application framework for Node.js that provides a robust set of features for building web and mobile applications.
# After installing Node.js proceed to installing Express at https://expressjs.com/en/starter/installing.html

# Installing on Ubuntu:
sudo apt update
sudo apt install nodejs npm -y

# Verify installation
node -v  # or node --version
npm -v

# Alternative: Install using NodeSource repository
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs
```

#### 🏗️ Creating a Node.js Project
```bash
# Create project directory - Created a directory called UserService-api and installed nodejs on WSL
mkdir UserService-api && cd UserService-api

# Initialize package.json - to initialize a new Node.js project, you can use the command `npm init` and follow the prompts to create a package.json file.
npm init -y

# Install Express framework
npm install express
# The command npm install --save express will install Express and add it as a dependency in your package.json file.

# Install development dependencies
npm install --save-dev nodemon
```

#### 🌐 Sample Express Application
Create `index.js`:

```javascript
// Copy the code from https://expressjs.com/en/starter/hello-world.html and paste it in an index.js file
const express = require('express');
const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(express.json());

// Routes
app.get('/', (req, res) => {
  res.json({
    message: 'Hello from Docker!',
    timestamp: new Date().toISOString(),
    version: '1.0.0'
  });
});

app.get('/health', (req, res) => {
  res.status(200).json({ status: 'healthy' });
});

// Error handling
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ error: 'Something went wrong!' });
});

app.listen(PORT, '0.0.0.0', () => {
  console.log(`Server running on port ${PORT}`);
});

// Once done run the command `node index.js` to start your Express application.
```

### 🐳 **Dockerfile for Node.js Applications**

#### ✅ **Basic Dockerfile for Node App**
```dockerfile
FROM node:latest
WORKDIR /app
ADD . .
RUN npm install
CMD node index.js
```

#### ✅ **Optimized Dockerfile**
```dockerfile
# Use Alpine version for smaller size
FROM node:18-alpine

# The `WORKDIR` instruction sets the working directory inside the container to `/app`.
WORKDIR /app

# Copy package files first (better caching)
# The `ADD` instruction copies the application code from the host machine into the container.
COPY package*.json ./

# The `RUN` instruction installs the application dependencies specified in the package.json file.
RUN npm ci --only=production && npm cache clean --force

# Create non-root user for security
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001

# Copy application code
COPY --chown=nodejs:nodejs . .

# Switch to non-root user
USER nodejs

# Expose port - Node.js applications typically listen on a specific port for incoming requests. In this case, the application is listening on port 3000.
EXPOSE 3000

# The `CMD` instruction specifies the command to run the application when the container starts.
CMD ["node", "index.js"]

# The difference between RUN and CMD is that RUN is used to build the image and execute commands during the image creation process, while CMD is used to specify the default command to run when a container is started from the image.
# The `RUN` instruction is executed during the image build process, while the `CMD` instruction is executed when a container is started from the image.
```

#### 🚫 **Essential .dockerignore**

When writing Dockerfiles, it's important to include a .dockerignore file to exclude unnecessary files and directories from the build context. This can help reduce the size of the image and improve build performance.

Create `.dockerignore`:

```
node_modules
npm-debug.log
Dockerfile
.dockerignore
.git
.gitignore
README.md
.env
.env.local
.env.development.local
.env.test.local
.env.production.local
coverage
.nyc_output
.DS_Store

# By excluding these files and directories, you can ensure that only the necessary files are included in the build context.
# The ADD . . adds everything in the current directory to the container's working directory.
# However, if you have a .dockerignore file, the contents of that file will be used to determine which files and directories to exclude from the build context.
# This means that any files or directories listed in .dockerignore will not be copied into the container, even if they are present in the current directory.
```

### 🏗️ **Building and Running**

```bash
# Build the image
docker build -t nodejs-app:latest .

# Run the container - Run this command to create the application on nodejs
docker run -d \
  --name nodejs-app \
  -p 3000:3000 \
  --restart unless-stopped \
  nodejs-app:latest

# Check if it's working
curl http://localhost:3000
```

---

## 🎯 Docker Best Practices

### 🏗️ **Dockerfile Optimization**

#### ❌ **Poor Practice Example**
```dockerfile
FROM node:latest
WORKDIR /app
COPY . .
RUN npm install
CMD ["npm", "start"]
```

**Problems:**
- Uses `latest` tag (unpredictable)
- Copies everything before installing dependencies (poor caching)
- Large image size
- No security considerations

#### ✅ **Best Practice Example**
```dockerfile
# Use specific version with Alpine for smaller size
FROM node:18-alpine

# Set working directory
WORKDIR /app

# Copy package files first for better layer caching
COPY package*.json ./

# Install only production dependencies
RUN npm ci --only=production && \
    npm cache clean --force && \
    rm -rf /tmp/*

# Create non-root user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001

# Copy source code
COPY --chown=nodejs:nodejs . .

# Switch to non-root user
USER nodejs

# Use EXPOSE for documentation
EXPOSE 3000

# Add health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:3000/health || exit 1

# Use specific command
CMD ["node", "server.js"]
```

### 🧱 **Caching and Layers**

Docker uses a layered filesystem, where each instruction in a Dockerfile creates a new layer in the image. When building an image, Docker caches the layers that have already been built, so that if you make changes to the Dockerfile, only the layers that have changed need to be rebuilt.

#### 🎯 **Optimal Layer Order**
To take advantage of caching, it's important to order the instructions in your Dockerfile in a way that minimizes the number of layers that need to be rebuilt when changes are made.

```dockerfile
FROM node:18-alpine

# 1. Set up system dependencies (changes rarely)
RUN apk add --no-cache dumb-init

# 2. Set working directory
WORKDIR /app

# 3. Copy dependency files (changes less frequently)
COPY package*.json ./

# 4. Install dependencies
RUN npm ci --only=production

# 5. Copy source code (changes most frequently)
COPY . .

# 6. Final configuration
ENTRYPOINT ["dumb-init", "--"]
CMD ["node", "server.js"]
```

#### ❌ **Example that will not use cache:**
```dockerfile
FROM node:14
WORKDIR /app
ADD . .
RUN npm install
CMD ["npm", "start"]
```

#### ✅ **Example that will use cache:**
```dockerfile
FROM node:14
WORKDIR /app
ADD package*.json ./
RUN npm install
ADD . .
CMD ["npm", "start"]
```

**Key Points:**
- Order your Dockerfile instructions from least to most likely to change
- Use COPY instead of ADD for adding files, as COPY is more explicit and easier to cache
- Leverage build arguments and environment variables to customize your builds without changing the Dockerfile
- Add the source code later in the Dockerfile to maximize caching of earlier layers
- Adding the source code later in the Dockerfile helps to ensure that changes to the source code do not invalidate the cache for earlier layers, which can significantly speed up the build process
- You can use the --cache-from option with docker build to specify an existing image to use as a cache source, further improving build times

### 🏔️ **Alpine Linux Benefits**

Linux Alpine distribution can be used to reduce the size of the docker image. It is a security-oriented, lightweight Linux distribution based on musl libc and busybox. Alpine images are often smaller than their Debian or Ubuntu counterparts, making them a popular choice for microservices and containerized applications.

```bash
# Size comparison
docker images node:18        # ~900MB
docker images node:18-alpine # ~170MB

# Pull Alpine variants - Almost every docker image out there has an Alpine variant.
docker pull nginx:alpine      # ~23MB vs ~140MB
docker pull python:3.11-alpine # ~50MB vs ~920MB
docker pull redis:alpine     # ~32MB vs ~117MB

# You can easily find these variants by searching for the image name followed by "-alpine".
# For example: search for "node-alpine"

# To pull an alpine version of an image, you can use the following command:
docker pull node:14-alpine
# OR to pull the alpine version of nginx:
docker pull nginx:alpine
# This pulls the latest Alpine version of the Nginx image.

# To pull other versions you need to specify the version tag:
docker pull nginx:alpine:1.21
```

#### 🔄 **Switching to Alpine:**
```dockerfile
FROM node:14-alpine
WORKDIR /app
ADD package*.json ./
RUN npm install
ADD . .
CMD ["npm", "start"]
```

This Dockerfile uses the Alpine version of the Node.js image, which is smaller and more lightweight than the standard version. By switching to Alpine, you can reduce the size of your Docker images and improve the performance of your containerized applications.

**Benefits:**
- Alpine images often have fewer vulnerabilities and a smaller attack surface, making them a more secure choice for production environments
- However, it's important to test your applications thoroughly when switching to Alpine, as some libraries or dependencies may behave differently in the Alpine environment

### 🏷️ **Tagging and Versioning Strategy**

Tags and versions allow you to have full control of what images are used in your deployments. By using specific tags, you can ensure that your application is always using the same version of a base image, which can help prevent unexpected issues caused by changes in the base image.

#### 📊 **Semantic Versioning Approach**
```bash
# Development
docker build -t myapp:dev .

# Feature branches
docker build -t myapp:feature-auth .

# Release candidates
docker build -t myapp:1.2.0-rc1 .

# Production releases
docker build -t myapp:1.2.0 .
docker build -t myapp:1.2 .
docker build -t myapp:1 .
docker build -t myapp:latest .
```

#### 🔄 **Git-based Tagging**
```bash
# Use git commit hash
docker build -t myapp:$(git rev-parse --short HEAD) .

# Use git branch
docker build -t myapp:$(git rev-parse --abbrev-ref HEAD) .

# Use git tag
docker build -t myapp:$(git describe --tags) .
```

#### 🏷️ **Using Tags**
```bash
# Tags are labels that you can assign to your Docker images to identify them easily.
# You can use tags to specify different versions of your images, such as "1.0", "1.1", etc.
# It's a good practice to use meaningful tags that reflect the purpose or content of the image.

# You can get a specific tag on docker hub by searching for the image and selecting the desired tag from the list of available tags.
# Older tags are still available on Docker Hub, allowing you to roll back to a previous version if needed.

# You can run a command like docker build -t highway:1.0 . to specify a specific tag when building your image.
docker build -t highway:1.0 .
# This helps with version control and ensures that you can easily reproduce a specific build if necessary.
```

#### 🔄 **Running containers using specific tags:**
```bash
# To run a container using a specific tag, you can use the following command:
docker run nginx:1.21

# For example, to run a container using the "1.0" tag of your image, you would run:
docker run my-image:1.0
# This will start a new container using the specified image and tag.
```

#### 🔄 **Tagging override:**
Whenever you make a change to your dockerfile and run a build using the same tag it overrides the previous image with the new one. This means that if you need to roll back to a previous version, you may need to re-tag the old image with the same tag before building the new one.

#### 🏷️ **Tagging images:**
```bash
# You can tag your images using the -t flag when building your image.
# For example, to tag your image as "my-image:1.0", you would run:
docker build -t my-image:1.0 .

# You can also add multiple tags to a single image by specifying the -t flag multiple times.
docker build -t my-image:1.0 -t my-image:latest .

# You can also change the existing tag of an image by running:
docker tag my-image:old my-image:new
# This will change the tag of the "old" image to "new".
# This is useful for managing different versions of your images and ensuring that you can easily switch between them as needed.
# This keeps both images available, allowing you to roll back to the previous version if necessary.

# You can now spin up a container using either tag:
docker run my-image:1.0
docker run my-image:latest
```

**Key Points:**
- It's a good practice to use semantic versioning for your images, so you can easily identify breaking changes and update your deployments accordingly
- Always using latest can cause issues because latest is a moving target and can change over time
- To avoid these issues, it's recommended to use specific version tags for your images in production environments
- This ensures that your application is always using a known, tested version of the base image, reducing the risk of unexpected issues
- You need to make sure that your application works correctly with the specific version of the base image you are using
- It's also a good idea to regularly update your base images to incorporate security patches and performance improvements

### 🔒 **Security Best Practices**

#### 👤 **Use Non-Root Users**
```dockerfile
FROM node:18-alpine

# Create app directory
WORKDIR /app

# Install dependencies as root
COPY package*.json ./
RUN npm ci --only=production

# Create and switch to non-root user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001

# Copy app source
COPY --chown=nodejs:nodejs . .

# Switch to non-root user
USER nodejs

CMD ["node", "app.js"]
```

---

## 🏪 Docker Registries

### 🌐 **Understanding Docker Registries**

Docker registries are centralized services for storing and distributing Docker images:

- **🏪 Storage**: Centralized image repository - This is a service that stores Docker images and allows you to share them
- **🤝 Sharing**: Distribute images across teams and environments
- **🔄 CI/CD Integration**: Used in CI/CD pipelines to automate the build and deployment process
- **🔐 Access Control**: Manage who can push/pull images

Popular registries include Docker Hub, Google Container Registry, and AWS Elastic Container Registry.

### 🐳 **Docker Hub - Public Registry**

This is a popular public registry for Docker images. You can create a free account and host your images there. You can also find many pre-built images for popular software and frameworks.

#### 🔑 **Authentication**
```bash
# Login to Docker Hub
docker login

# Login with username
docker login -u yourusername

# Logout
docker logout
```

#### 📤 **Pushing Images**
```bash
# To push an image to Docker Hub, you first need to tag it with your Docker Hub username:
docker tag my-image:1.0 myusername/my-image:1.0

# Then log in to Docker Hub with:
docker login

# Finally, push the image with:
docker push myusername/my-image:1.0

# Push all tags
docker push myusername/myapp --all-tags

# Example to push to my repo:
docker push njibrigthain100/brigthain:1.0

# To push images built using Dockerfile, you first need to build the image with:
docker build -t njibrigthain100/brigthain:1.0 .

# Then you can push it with:
docker push njibrigthain100/brigthain:1.0

# The name of the image is in the format `username/repo:tag`.
# This is because docker uses this format to uniquely identify images in the registry.
# And also how docker hub knows where to push the image.
```

#### 📥 **Pulling Images**
```bash
# To pull an image from Docker Hub, you can use:
docker pull myusername/my-image:1.0

# To pull from my repo I run:
docker pull njibrigthain100/brigthain:1.0

# Pull and run
docker run -d -p 8080:80 myusername/myapp:1.0
```

### 🏢 **Private Registries**

#### 🔒 **Docker Hub Private Repositories**
- **Free Tier**: You get 1 private repository for free with a Docker Hub account
- **Pro/Team Plans**: Private repositories require a paid Docker Hub plan
- **Features**: It gives us the ability to store both private and public images - Access control, automated builds, webhooks
- **Public repositories**: Great for open-source projects
- **Private repositories**: To keep your images secure, you can use private repositories

#### ☁️ **Cloud Provider Registries**

**AWS Elastic Container Registry (ECR)**
```bash
# Get login token
aws ecr get-login-password --region us-east-1 | \
docker login --username AWS --password-stdin \
123456789.dkr.ecr.us-east-1.amazonaws.com

# Tag and push
docker tag myapp:latest 123456789.dkr.ecr.us-east-1.amazonaws.com/myapp:latest
docker push 123456789.dkr.ecr.us-east-1.amazonaws.com/myapp:latest
```

**Google Container Registry (GCR)**
```bash
# Configure authentication
gcloud auth configure-docker

# Tag and push
docker tag myapp:latest gcr.io/my-project/myapp:latest
docker push gcr.io/my-project/myapp:latest
```

**Azure Container Registry (ACR)**
```bash
# Login to ACR
az acr login --name myregistry

# Tag and push
docker tag myapp:latest myregistry.azurecr.io/myapp:latest
docker push myregistry.azurecr.io/myapp:latest
```

---

## 🔧 Advanced Commands

### 🔍 **Docker Inspect**

This command allows you to view detailed information about Docker objects such as containers, images, volumes, and networks. You can use it to inspect the configuration, state, and metadata of these objects.

```bash
# Inspect container (returns JSON)
docker inspect <container_id_or_name>

# This will return a JSON object containing detailed information about the container, including its configuration, network settings, and resource usage.

# Inspect image
docker inspect <image_name_or_id>

# This will return information about the image, including its layers, size, and creation date.

# Get specific values using format
docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' container-name

# Get container state
docker inspect --format='{{.State.Status}}' container-name

# Get port mappings
docker inspect --format='{{.NetworkSettings.Ports}}' container-name
```

#### 🎯 **Useful Inspection Queries**
```bash
# Get IP address
docker inspect --format='{{.NetworkSettings.IPAddress}}' container-name

# For example, to get just the IP address of a container, you can run:
docker inspect <container_id_or_name> | jq '.[0].NetworkSettings.IPAddress'

# Get environment variables
docker inspect --format='{{.Config.Env}}' container-name

# Get mounted volumes
docker inspect --format='{{.Mounts}}' container-name

# Get resource limits
docker inspect --format='{{.HostConfig.Memory}}' container-name
```

**Usage:**
- This is used for debugging and troubleshooting Docker objects
- You can use it to gather information about the state and configuration of your containers and images
- This can help you identify issues and optimize your Docker setup
- You can also use it to monitor resource usage and performance metrics
- The output of `docker inspect` can be quite verbose, so you may want to use tools like `jq` to filter and format the JSON output for easier reading

### 📊 **Docker Logs**

This command allows you to view the logs generated by a container. You can use it to troubleshoot issues and monitor the behavior of your applications.

```bash
# View container logs
docker logs <container_id_or_name>

# This will display the standard output and error streams of the container.

# Follow logs in real-time
docker logs -f <container_id_or_name>

# This is useful for monitoring the logs as they are generated.

# Show timestamps
docker logs -t container-name

# Limit log lines
docker logs --tail 100 <container_id_or_name>

# You can combine it with other options like `--tail` to limit the number of lines displayed

# Filter by time
docker logs --since "2023-01-01T00:00:00" container-name
docker logs --until "2023-01-02T00:00:00" container-name

# Combine options
docker logs -f --tail 50 --since "1h" container-name
```

### 💻 **Container Shell Access (Bash into containers)**

You can use the `docker exec` command to start a new Bash session inside a running container.

```bash
# Start interactive bash session
docker exec -it <container_id_or_name> bash

# This will give you an interactive Bash shell inside the container.
# You can then run commands as if you were logged into the container's operating system.
# This is useful for debugging and troubleshooting issues inside the container.

# For Alpine containers (no bash)
docker exec -it container-name sh

# Execute single command
docker exec container-name ls -la /app

# Run command as different user
docker exec -u root -it container-name bash

# Execute with environment variables
docker exec -e NODE_ENV=development -it container-name bash
```

### 📁 **File Operations**

Copy files between host and container:

```bash
# Copy file from host to container
docker cp ./local-file.txt container-name:/app/

# Copy file from container to host
docker cp container-name:/app/config.json ./

# Copy directory
docker cp ./src/ container-name:/app/src/

# Copy with different ownership
docker cp --chown=1000:1000 ./app.js container-name:/app/
```

### 📊 **Container Statistics**

Monitor resource usage:

```bash
# Show real-time stats for all containers
docker stats

# Show stats for specific containers
docker stats container1 container2

# Show stats without stream (one-time)
docker stats --no-stream

# Custom format
docker stats --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}"
```

---

## 🩺 Troubleshooting Tips

### 🚨 **Common Issues and Solutions**

#### 1. **Container Won't Start**
```bash
# Check container logs
docker logs container-name

# Inspect container configuration
docker inspect container-name

# Try running interactively
docker run -it image-name bash

# Check if image exists
docker images | grep image-name
```

#### 2. **Port Already in Use**
```bash
# Find what's using the port
netstat -tulpn | grep 8080
lsof -i :8080  # On macOS/Linux

# Use different port
docker run -p 8081:80 nginx  # Instead of 8080:80

# Kill process using port
sudo kill -9 $(lsof -t -i:8080)
```

#### 3. **Permission Denied Errors**
```bash
# Run as current user
docker run --user $(id -u):$(id -g) image-name

# Fix file permissions
sudo chown -R $USER:$USER /path/to/directory

# Run container as root temporarily
docker exec -u root -it container-name bash
```

#### 4. **Out of Disk Space**
```bash
# Check Docker disk usage
docker system df

# Clean up unused resources
docker system prune

# Aggressive cleanup (removes everything not in use)
docker system prune -a

# Remove unused volumes
docker volume prune

# Remove unused networks
docker network prune
```

#### 5. **Container Exits Immediately**
```bash
# Check exit code
docker ps -a

# Run with interactive terminal
docker run -it image-name

# Override entrypoint
docker run -it --entrypoint bash image-name

# Check if main process exits
docker logs container-name
```

#### 6. **DNS/Network Issues**
```bash
# Test network connectivity
docker run --rm alpine ping google.com

# Check DNS resolution
docker run --rm alpine nslookup google.com

# Use host network
docker run --network host image-name

# Check container IP
docker inspect --format='{{.NetworkSettings.IPAddress}}' container-name
```

---

## 📚 Summary

This comprehensive Docker tutorial has covered:

### 🎯 **Core Concepts**
- ✅ **Container Technology**: Understanding containers vs VMs
- ✅ **Image Management**: Pulling, building, and tagging images
- ✅ **Container Lifecycle**: Creating, running, and managing containers

### 🛠️ **Practical Skills**
- ✅ **Port Mapping**: Exposing applications to the host
- ✅ **Volume Management**: Persistent data and file sharing
- ✅ **Dockerfile Creation**: Building custom images
- ✅ **Registry Usage**: Sharing images via Docker Hub and private registries

### 🚀 **Advanced Topics**
- ✅ **Best Practices**: Security, optimization, and layer caching
- ✅ **Node.js Integration**: Containerizing JavaScript applications
- ✅ **Troubleshooting**: Common issues and debugging techniques
- ✅ **Production Readiness**: Multi-stage builds and Alpine images

### 💡 **Key Takeaways**

| Aspect | Best Practice |
|--------|---------------|
| **🏷️ Tagging** | Use semantic versioning, avoid `latest` in production |
| **🔒 Security** | Run as non-root user, scan for vulnerabilities |
| **⚡ Performance** | Use Alpine images, optimize layer caching |
| **📦 Organization** | Use .dockerignore, meaningful container names |
| **🔍 Monitoring** | Implement health checks, monitor resource usage |

Docker is an essential tool for modern application deployment, providing **consistency**, **efficiency**, and **scalability** across development and production environments. It enables teams to build, ship, and run applications anywhere with confidence.

---

## 🔗 Additional Resources

### 📖 **Official Documentation**
- [Docker Documentation](https://docs.docker.com/)
- [Docker Hub](https://hub.docker.com/)
- [Dockerfile Best Practices](https://docs.docker.com/develop/dev-best-practices/)

### 🛠️ **Tools and Extensions**
- [Docker Compose](https://docs.docker.com/compose/) - Multi-container applications
- [Docker Swarm](https://docs.docker.com/engine/swarm/) - Container orchestration
- [Watchtower](https://containrrr.dev/watchtower/) - Automatic container updates

### 🔒 **Security Resources**
- [Docker Security Best Practices](https://docs.docker.com/engine/security/)
- [CIS Docker Benchmark](https://www.cisecurity.org/benchmark/docker)
- [Snyk Container Security](https://snyk.io/product/container-vulnerability-management/)

### 📚 **Learning Resources**
- [Docker Tutorials](https://docker-curriculum.com/)
- [Play with Docker](https://labs.play-with-docker.com/)
- [Docker Training](https://www.docker.com/resources/trainings/)

---

> 🎉 **Congratulations!** You now have a comprehensive understanding of Docker. Start containerizing your applications and experience the benefits of modern deployment practices!
