# Docker Tutorial - Complete Guide

## Table of Contents
- [What is Docker](#what-is-docker)
- [Container vs VM](#container-vs-vm)
- [Benefits of Docker](#benefits-of-docker)
- [Installing Docker](#installing-docker)
- [Docker Images and Containers](#docker-images-and-containers)
- [Working with Images](#working-with-images)
- [Running Containers](#running-containers)
- [Port Management](#port-management)
- [Container Management](#container-management)
- [Container Naming](#container-naming)
- [Docker PS Commands](#docker-ps-commands)
- [Docker Volumes](#docker-volumes)

---

## What is Docker

Docker is a powerful containerization platform that provides:

- **Isolated Environment**: Tool for running applications in an isolated environment
- **Consistency**: Applications run the same environment whether in staging or production
- **Standardization**: Standard for software deployment, making packaging applications easier
- **Industry Adoption**: Every company is adopting Docker for its reliability and efficiency

---

## Container vs VM

### Containers
- **Abstraction Layer**: Abstraction at the app layer that packages code and dependencies together
- **Resource Sharing**: Multiple containers share the OS kernel, running as isolated processes
- **Lightweight**: Does not require a full operating system
- **Efficiency**: Faster startup and less resource usage

### Virtual Machines  
- **Hardware Abstraction**: Abstraction of physical hardware turning one server into many
- **Hypervisor**: Allows multiple VMs to run on a single machine
- **Full OS**: Each VM includes a full copy of operating system, applications, binaries and libraries
- **Resource Heavy**: Takes up tens of GBs and can be slow to boot

---

## Benefits of Docker

- ⚡ **Speed**: Run containers in seconds instead of minutes
- 💾 **Resource Efficiency**: Less resources, less disk space, less memory
- 🚀 **No Full OS Required**: Lightweight compared to VMs
- 🔧 **Easy Deployment**: Simplified deployment and testing processes

---

## Installing Docker

### Installation Options

1. **Official Documentation**: Visit [https://docs.docker.com/install](https://docs.docker.com/install)

2. **Amazon Linux 2023**:
   ```bash
   dnf install docker
   systemctl start docker
   ```

3. **Docker Desktop for Windows**: 
   - Download Docker Desktop
   - Install WSL (Windows Subsystem for Linux)
   - Ensure Docker daemon is running

### Important Notes
- Always make sure the Docker daemon is running when using Docker
- Docker Desktop provides a GUI interface for easier management

---

## Docker Images and Containers

### Images
- **Template**: Template for creating an environment of your choice
- **Snapshot**: Contains everything your app needs to run
- **Versions**: Can create multiple versions and point to specific versions
- **Portable**: Can be shared and distributed

### Containers
- **Running Instance**: A container is a running instance of an image
- **Lifecycle**: You have an image → then you run a container from that image

### Example Image Listing
```
REPOSITORY   TAG       IMAGE ID       CREATED      SIZE
nginx        latest    33e0bbc7ca9e   2 days ago   279MB
httpd        latest    3198c1839e1a   7 days ago   174MB
```

### Understanding Tags
- **Latest Tag**: Default tag when none specified
- **Version Control**: Tags help specify which version of the image to use
- **Best Practice**: Using explicit tags helps avoid unexpected updates

---

## Working with Images

### Pulling Images

1. **Docker Hub**: Navigate to [https://hub.docker.com](https://hub.docker.com)
   - Public registry for downloading images
   - Use your Docker credentials to login
   - Explore and search for needed images

2. **Pull Command**:
   ```bash
   docker pull nginx
   docker pull nginx:latest
   docker pull nginx:1.21
   ```

3. **List Images**:
   ```bash
   docker images
   ```

---

## Running Containers

### Basic Container Operations

```bash
# Run container with image name and tag
docker run nginx:latest

# Run container in detached mode
docker run -d nginx:latest

# List running containers
docker ps
docker container ls
```

### Container Lifecycle Commands

```bash
# Stop container
docker stop <container_id_or_name>
docker stop ebe278d0f893

# Start container
docker start <container_id_or_name>
docker start ebe278d0f893

# Check running containers
docker ps
```

---

## Port Management

### Exposing Ports

Port mapping allows access from host to container:

```bash
# Map host port 8080 to container port 80
docker run -d -p 8080:80 nginx:latest

# Access application at http://localhost:8080
```

### Multiple Port Mapping

```bash
# Map multiple ports to same container port
docker run -d -p 8080:80 -p 3000:80 httpd:latest
```

This maps both host ports 8080 and 3000 to container port 80.

---

## Container Management

### Removing Containers

```bash
# Remove specific container
docker rm <container_id_or_name>
docker rm ebe278d0f893

# Remove all stopped containers
docker container prune

# Remove all containers (including running ones)
docker rm -f $(docker ps -a -q)
```

### Managing Images

```bash
# Remove specific image
docker rmi <image_id_or_name>
docker rmi 33e0bbc7ca9e

# Remove all images
docker rmi $(docker images -q)
```

### Useful Container Commands

```bash
# Show all containers (including stopped)
docker ps -a

# List all container IDs
docker ps -a -q
```

---

## Container Naming

### Why Name Containers?
- Makes container management easier
- Avoid random Docker-generated names
- Better organization and identification

### Naming Examples

```bash
# Specify container name
docker run -d --name mynginx -p 8080:80 nginx:latest

# View container names
docker ps
```

**Best Practice**: Always name your containers for easier management.

---

## Docker PS Commands

### Basic Docker PS

```bash
# Lists all running containers
docker ps
```

Shows: Container ID, Image, Command, Created time, Status, Ports, and Names

### Docker PS Formatting

#### What is `docker ps --format` used for?
- **Customizes output format** of docker ps command
- **Controls information display** and formatting
- **Creates custom layouts** (tables, lists, etc.) instead of default format
- **Makes output scriptable** and easier to parse in automation
- **Filters information** to show only needed data

#### Basic Format Commands

```bash
# Formatted table output
docker ps --format "table {{.ID}}\t{{.Image}}\t{{.Command}}\t{{.CreatedAt}}\t{{.Status}}\t{{.Ports}}\t{{.Names}}"

# All containers (including stopped)
docker ps -a --format "table {{.ID}}\t{{.Image}}\t{{.Command}}\t{{.CreatedAt}}\t{{.Status}}\t{{.Ports}}\t{{.Names}}"

# Filter by status
docker ps -a --filter "status=exited" --format "table {{.ID}}\t{{.Image}}\t{{.Status}}\t{{.Names}}"
```

#### Creating Variables and Aliases

**In WSL/bash:**

```bash
# Create a variable for the format string
DOCKER_FORMAT="table {{.ID}}\t{{.Image}}\t{{.Command}}\t{{.CreatedAt}}\t{{.Status}}\t{{.Ports}}\t{{.Names}}"

# Use the variable
docker ps --format "$DOCKER_FORMAT"

# Make it permanent in ~/.bashrc
export DOCKER_FORMAT="table {{.ID}}\t{{.Image}}\t{{.Command}}\t{{.CreatedAt}}\t{{.Status}}\t{{.Ports}}\t{{.Names}}"

# Create useful aliases
alias dps='docker ps --format "table {{.ID}}\t{{.Image}}\t{{.Command}}\t{{.CreatedAt}}\t{{.Status}}\t{{.Ports}}\t{{.Names}}"'
alias dpsa='docker ps -a --format "table {{.ID}}\t{{.Image}}\t{{.Command}}\t{{.CreatedAt}}\t{{.Status}}\t{{.Ports}}\t{{.Names}}"'
```

### Available Format Fields

| Field | Description |
|-------|-------------|
| `{{.ID}}` | Container ID |
| `{{.Image}}` | Image name |
| `{{.Command}}` | Command that started container |
| `{{.CreatedAt}}` | When container was created |
| `{{.Status}}` | Current status |
| `{{.Ports}}` | Port mappings |
| `{{.Names}}` | Container names |
| `{{.Size}}` | Container size |
| `{{.Labels}}` | Container labels |

### Format Examples

```bash
# Simple list format
docker ps --format "{{.Names}}: {{.Status}}"

# Custom message format
docker ps --format "{{.Names}} is running {{.Image}}"

# JSON format
docker ps --format "{{json .}}"

# Simple table
docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}"
```

---

## Docker Volumes

### What are Docker Volumes?

Docker volumes are used to persist data generated by and used by Docker containers.

#### Key Features:
- **Data Persistence**: Exists outside of container filesystem
- **Sharing**: Can be shared among multiple containers  
- **Management**: Stored in Docker-managed location (`/var/lib/docker/volumes/` on Linux)
- **Preferred Method**: Recommended mechanism for persisting data

### Volume Management Commands

```bash
# Create a volume
docker volume create my_volume

# List all volumes
docker volume ls

# Inspect a volume
docker volume inspect my_volume

# Remove a volume
docker volume rm my_volume
```

**⚠️ Important**: You cannot remove a volume that's in use by a container. Stop and remove the container first.

### Using Volumes in Containers

#### Named Volumes

```bash
# Using -v flag
docker run -v my_volume:/data my_image

# Using --mount flag
docker run --mount source=my_volume,target=/data my_image
```

#### Bind Mounts (Host to Container)

```bash
# Mount host directory to container
docker run -v /host/path:/container/path my_image

# Using --mount flag
docker run --mount type=bind,source=/host/path,target=/container/path my_image
```

### Practical Volume Examples

#### Website Hosting Example

```bash
# Create folder structure
mkdir website
echo "<h1>Hello Docker!</h1>" > website/index.html

# Run nginx with volume mount
docker run --name website -v $(pwd)/website:/usr/share/nginx/html -d nginx
```

#### Path Examples

**Full Windows WSL Path:**
```
/mnt/c/Users/Owner/Downloads/GitRepos/cognitech-repos/cognitech-platform-all-codes-repo/Docker/website/index.html
```

**Using Current Directory:**
```bash
# Mount current directory
docker run --name website -v $(pwd):/usr/share/nginx/html -d nginx

# Mount specific file
docker run --name website -v $(pwd)/index.html:/usr/share/nginx/html/index.html -d nginx
```

#### Volume Mounting Rules

| Mount Type | Works | Example |
|------------|-------|---------|
| **Directory → Directory** | ✅ | `-v $(pwd):/usr/share/nginx/html` |
| **File → File** | ✅ | `-v $(pwd)/file.html:/usr/share/nginx/html/index.html` |
| **File → Directory** | ❌ | `-v $(pwd)/file.html:/usr/share/nginx/html/` |

#### Multiple Files in Same Directory

**❌ What doesn't work:**
```bash
# Can't mount multiple files to same directory
docker run -v file1.html:/usr/share/nginx/html/file1.html \
           -v file2.html:/usr/share/nginx/html/file2.html nginx
```

**✅ What works:**
```bash
# Option 1: Mount entire directory
docker run -v $(pwd):/usr/share/nginx/html nginx

# Option 2: Use docker cp
docker run -d --name web nginx
docker cp file1.html web:/usr/share/nginx/html/
docker cp file2.html web:/usr/share/nginx/html/

# Option 3: Different subdirectories
docker run -v file1.html:/usr/share/nginx/html/pages/file1.html \
           -v file2.html:/usr/share/nginx/html/docs/file2.html nginx
```

### Web Server Comparison

#### Nginx vs Apache (httpd)

| Web Server | Default Directory | Image | Port |
|------------|-------------------|-------|------|
| **Nginx** | `/usr/share/nginx/html` | `nginx:latest` | 80 |
| **Apache** | `/usr/local/apache2/htdocs` | `httpd:latest` | 80 |

#### Correct Usage Examples

**Nginx:**
```bash
docker run -d --name nginx-site -p 8001:80 -v $(pwd):/usr/share/nginx/html:ro nginx:latest
```

**Apache:**
```bash
docker run -d --name apache-site -p 8001:80 -v $(pwd):/usr/local/apache2/htdocs:ro httpd:latest
```

#### Troubleshooting Volumes

```bash
# Check what's mounted in container
docker exec website ls -la /usr/share/nginx/html

# Check file permissions
docker exec website ls -la /usr/share/nginx/html/index.html
```

**Common Issues:**
- **403 Forbidden**: Usually permissions issue (`chmod 755 directory`)
- **File not found**: Check path and mounting syntax
- **Permission denied**: Fix directory permissions
- **Wrong web server**: Match image with correct directory path

**Permission Fix:**
```bash
# Fix directory permissions for WSL/home directory
chmod o+rx ~

# Or create dedicated web directory
mkdir ~/webfiles
chmod 755 ~/webfiles
```

---

## Best Practices

1. **Always name your containers** for easier management
2. **Use specific image tags** instead of `latest` in production
3. **Use volumes** for data persistence
4. **Clean up unused resources** regularly with `docker system prune`
5. **Use environment variables** for configuration
6. **Check container logs** with `docker logs <container_name>`
7. **Match web server images** with correct directory paths
8. **Set proper permissions** for volume mounts

---

## Quick Reference Commands

```bash
# Essential Commands
docker pull <image>              # Download image
docker run -d --name <name> <image>  # Run container detached
docker ps                        # List running containers
docker ps -a                     # List all containers
docker stop <container>          # Stop container
docker rm <container>            # Remove container
docker rmi <image>              # Remove image

# Port Mapping
docker run -d -p <host_port>:<container_port> <image>

# Volume Commands
docker volume create <volume>    # Create volume
docker volume ls                 # List volumes
docker run -v <volume>:<path> <image>  # Use volume
docker run -v $(pwd):<path> <image>    # Mount current directory

# Useful Aliases
alias dps='docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}"'
alias dlog='docker logs'
alias dexec='docker exec -it'
alias dclean='docker system prune -f'
```

---

## Troubleshooting Guide

### Common Errors and Solutions

| Error | Cause | Solution |
|-------|-------|----------|
| **403 Forbidden** | Directory permissions | `chmod 755 <directory>` |
| **Port already in use** | Another service using port | Use different port or stop conflicting service |
| **Cannot remove volume** | Volume in use by container | Stop and remove container first |
| **Image not found** | Wrong image name/tag | Check Docker Hub for correct name |
| **File not found in container** | Wrong mount path | Verify source and target paths |

### Debugging Commands

```bash
# Check container logs
docker logs <container_name>

# Execute commands inside container
docker exec -it <container_name> /bin/bash

# Inspect container details
docker inspect <container_name>

# Check system resource usage
docker system df

# View real-time container stats
docker stats
```
