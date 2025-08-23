DOCKER TUTORIAL AMIGOS CODE
What is docker:
-	Docker is a tool for tunning applications in an isolated environment
-	Similar to a virtual machine
-	App run in the same environment so if it works in staging its going to work in production as well
-	Standard for software deployment because it makes it easier for packaging applications
-	Every company is adopting docker because of that
Container vs VM
-	Container is an abstraction at the app layer that packages code and dependencies together. Multiple containers can run on the same machine and share the OS kernel with other containers, each running as isolated processes in user space
-	Does not require a full operating system
-	Virtual machine is an abstraction of physical hardware turning one server into many servers. The hypervisor allows multiple VMs to run on a single machine. Each VM includes a full copy of an operating system, the application, necessary binaries and libraries taking up tens of GBs. VMS can also be slow to boot. 
-	 
Benefits of using Docker:
-	You can run a container in seconds instead of minutes
-	Less resources results in less dick space
-	Less memory and you don’t need a full OS 
-	Deployment and testing
Installing Docker:
-	To install docker you go to https://docs.docker.com/install 
-	I used amazon Linux 2023 and installed docker using the commands
o	dnf install docker
o	systemctl start docker to start docker
-	I also downloaded docker desktop for windows. You will need to install WSL with docker for windows 
-	Make sure that the docker daemon is running when you are using docker
Docker images and containers:
-	Image is a template for creating an environment of your choice
-	Its also a snapshot. You can create multiple versions and point to that version. The image contains everything your app needs to run
-	A container is a running instance of an image
-	So you have an image then you run a container from that image 
REPOSITORY   TAG       IMAGE ID       CREATED      SIZE
nginx        latest    33e0bbc7ca9e   2 days ago   279MB
httpd        latest    3198c1839e1a   7 days ago   174MB
-	Here the tag is latest and its very important
-	Tags help you specify which version of the image you want to use
-	If you don't specify a tag, Docker uses "latest" by default
-	Using explicit tags helps avoid unexpected updates when the image changes
Pulling docker images:
-	Navigate to https://hub.docker.com 
-	This is public registry . A place where you can download images 
-	Login to docker hub is the same as my docker credentials
-	Go to explore and search for the image that you need
-	To pull an image we run the command docker pull plus package. For instance docker pull nginx 
-	This is how you pull an image from docker hub
-	Docker images to see the images in your system 
Running containers:
-	To run a container using an image you use the command docker run plus image name and tag
-	Docker run nginx: latest where latest is the tag and nginx is the image name
-	Docker container ls list all the running containers
-	Docker run -d nginx:latest runs the container in detached mode 
-	Docker ps checks the list of running containers
Exposing ports:
-	To expose the container ports to the public use the following commands 
-	This allows us to go from the host to the container 
-	b-kargong@GWT-PF3DVJ84:~$ docker ps
-	CONTAINER ID   IMAGE          COMMAND                  CREATED         STATUS         PORTS     NAMES
-	ebe278d0f893   nginx:latest   "/docker-entrypoint.…"   2 minutes ago   Up 2 minutes   80/tcp    dreamy_blackwell
-	b-kargong@GWT-PF3DVJ84:~$
-	To stop a container run docker stop plus container id. For instance docker stop docker stop ebe278d0f893 or by using the container name
-   To start a container run docker start plus container id. For instance docker start ebe278d0f893 or by using the container name
-	Then you can check with the command docker ps
-	So to access the application from our host we run docker run -d -p 8080:80 nginx:latest. This maps the host port 8080 to the container on port 80
- you can also specify the container name by passing the --name flag. For instance docker run -d --name mynginx -p 8080:80 nginx:latest 
Exposing multiple ports:
-	To expose multiple ports run the command docker run -d -p 8080:80 -p 3000:80 httpd:latest
-	This maps the host ports 8080 and 3000 to the containers port 80
Managing containers: 
-	This explains how to start and stop the containers. Please see above for the relevant commands.
-	To remove or delete a container run docker rm plus container id. For instance docker rm ebe278d0f893 or by using the container name
-	To remove all stopped containers run docker container prune
-	To remove an image run docker rmi plus image id. For instance docker rmi 33e0bbc7ca9e or by using the image name
-   Docker ps -a shows all containers, including stopped ones.
-   Docker ps -a -q list all container IDs.
-   Docker rm $(docker ps -a -q) removes all containers. This command does not remove running containers. 
-   To remove all containers including running ones, you can use docker rm -f $(docker ps -a -q).
-   Docker rmi $(docker images -q) removes all images.
Naming Containers:
-   You can also specify the container name by passing the --name flag. For instance docker run -d --name mynginx -p 8080:80 nginx:latest
-   Docker will usually give you a random name for the container if you don't specify one
-   You can view the container name by running docker ps
-  Always name your containers to make it easier to manage them
Docker ps:
-  Lists all running containers
-  Shows container ID, image, command, created time, status, ports, and names
-  What is docker ps --format used for:
   * Customizes the output format of docker ps command
   * Controls exactly what information is displayed and how it's formatted
   * Creates tables, lists, or custom layouts instead of default format
   * Makes output more scriptable and easier to parse in automation
   * Filters information to show only the data you need
-  Command to format a docker ps output:
   docker ps --format "table {{.ID}}\t{{.Image}}\t{{.Command}}\t{{.CreatedAt}}\t{{.Status}}\t{{.Ports}}\t{{.Names}}"
-  To see ALL containers (including stopped ones) in table format:
   docker ps -a --format "table {{.ID}}\t{{.Image}}\t{{.Command}}\t{{.CreatedAt}}\t{{.Status}}\t{{.Ports}}\t{{.Names}}"
-  You can also filter the output by using the --filter flag. For instance, to see only exited containers:
   docker ps -a --filter "status=exited" --format "table {{.ID}}\t{{.Image}}\t{{.Command}}\t{{.CreatedAt}}\t{{.Status}}\t{{.Ports}}\t{{.Names}}"
-  You can also use the --format flag to customize the output. For example, to show only the container names and their status:
   docker ps --format "table {{.Names}}\t{{.Status}}"
-  Or you can export the above to make it a variable and call it in your script:
   # In WSL/bash, create a variable for the format string:
   DOCKER_FORMAT="table {{.ID}}\t{{.Image}}\t{{.Command}}\t{{.CreatedAt}}\t{{.Status}}\t{{.Ports}}\t{{.Names}}" 
   # Then use it:
   docker ps --format "$DOCKER_FORMAT"
   
   # To make it permanent, add to ~/.bashrc:
   export DOCKER_FORMAT="table {{.ID}}\t{{.Image}}\t{{.Command}}\t{{.CreatedAt}}\t{{.Status}}\t{{.Ports}}\t{{.Names}}"
   
   # Or create aliases for easier use:
   alias dps='docker ps --format "table {{.ID}}\t{{.Image}}\t{{.Command}}\t{{.CreatedAt}}\t{{.Status}}\t{{.Ports}}\t{{.Names}}"'
   alias dpsa='docker ps -a --format "table {{.ID}}\t{{.Image}}\t{{.Command}}\t{{.CreatedAt}}\t{{.Status}}\t{{.Ports}}\t{{.Names}}"'

Docker ps format fields:
-  Available format fields you can use:
   * {{.ID}} - Container ID
   * {{.Image}} - Image name
   * {{.Command}} - Command that started container
   * {{.CreatedAt}} - When container was created
   * {{.Status}} - Current status
   * {{.Ports}} - Port mappings
   * {{.Names}} - Container names
   * {{.Size}} - Container size
   * {{.Labels}} - Container labels
-  Format examples:
   * Simple list: docker ps --format "{{.Names}}: {{.Status}}"
   * Custom message: docker ps --format "{{.Names}} is running {{.Image}}"
   * JSON format: docker ps --format "{{json .}}"
   * Table format: docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}"
Docker Volumes:
-  Docker volumes are used to persist data generated by and used by Docker containers.
-  When you create a volume, it exists outside of the container filesystem and can be shared among multiple containers.
-  Volumes are stored in a part of the host filesystem which is managed by Docker (`/var/lib/docker/volumes/` on Linux).
-  You can create a volume using the command: `docker volume create my_volume`
-  To use a volume in a container, you can use the `-v` or `--mount` flag:
   * `docker run -v my_volume:/data my_image`
   * `docker run --mount source=my_volume,target=/data my_image`
-  To list all volumes: `docker volume ls`
-  To inspect a volume: `docker volume inspect my_volume`
-  To remove a volume: `docker volume rm my_volume`
-  Note: You cannot remove a volume that is in use by a container. You must stop and remove the container first.
- It allows us to share data between host and container or between containers.
- Volumes are the preferred mechanism for persisting data generated by and used by Docker containers.
-  To share volume between host and container, you can use the `-v` or `--mount` flag when running a container:
   * `docker run -v /host/path:/container/path my_image`
   * `docker run --mount type=bind,source=/host/path,target=/container/path my_image`
Mount volume from host to container:
   * `docker run -v /host/path:/container/path my_image`
   * `docker run --mount type=bind,source=/host/path,target=/container/path my_image`
   - Create a folder called website and have a file called index.html in it
   - command is docker run --name website -v $(pwd)/website:/usr/share/nginx/html -d nginx
   - Where pwd is the current working directory and website is the folder that contains the index.html file.
   - To point to the index.html file in the host from wsl, you can use the following path:
   - /mnt/c/Users/Owner/Downloads/GitRepos/cognitech-repos/cognitech-platform-all-codes-repo/Docker/website/index.html
   - if the index.html file is found in the present working directory you do not need to specify the full path
   - You can also use the relative path like this:
   - ./website/index.html
   - you can simply use $(pwd) to get the current working directory and not have to specify the index.html file path.
   - if there are multiple index.html files in the present working directory you can use the following command:
   - docker run --name website -v $(pwd)/index.html:/usr/share/nginx/html -d nginx
   - This will mount the specific index.html file into the container, allowing you to work with that file directly.
   - The command docker exec website ls -la /usr/share/nginx/html shows you the contents of the /usr/share/nginx/html directory inside the container, which is where the index.html file is mounted.
   - The nginx documentation on docker hub shows you how to mount the volume. See here for more details https://hub.docker.com/_/nginx
   -  Docker exec -it name of container bash eg docker exec -it website bash. This command allows you to access the container's shell.
   - This command allows you to create the volume in read only mode docker run -d -p 8000:80 --name angel -v $(pwd)/websites:/usr/share/nginx/html:ro nginx:latest
   - ro stands for read-only mode, meaning the container can read the files but cannot modify them.
Customize website:
   - To customize out website you can go to this website and get free templates for testing https://startbootstrap.com/themes/landing-pages
   - Download the template and extract it to the websites folder
   - this might not work if the directory does not have an index.html file
   - You can also create a simple index.html file in the websites folder with the following content
Sharing volumes between containers:
   - To share a volume between containers you can use the command --volumes-from as shown below
   - docker run --name kali -d -p 8082:80 --volumes-from kah nginx:latest
   - The --volumes-from option allows you to share volumes between containers. This means that the kali container will have access to the same volumes as the kah container.
Dockerfile:
   - Dockerfiles are used to build our own images
   - It is a text file that contains all the commands to assemble an image
   - it contains a list of steps on how to create our own image
   - It is a blueprint for creating a Docker image
   - The following link provides more information on how to create a Dockerfile: https://docs.docker.com/engine/reference/builder/
   - its a series of steps that define how your image is built
   - Every dockerfile has to have the FROM keyword
   - The FROM keyword specifies the base image to use for the new image
   - images should contain everything that your application needs to run 
Creating a dockerfile:
   - To create a Dockerfile, you can use a text editor to create a new file named "Dockerfile" (with no file extension) in your project directory.
   - The Dockerfile should start with the FROM keyword, followed by the base image you want to use. You will always use a base image as the starting point for your Dockerfile.
   - The ADD instruction is used to copy files and directories from your host machine into the Docker image.
   - You can then add additional instructions to install dependencies, copy files, and configure the image as needed.
   Example dockerfile:
   FROM nginx:latest
   ADD . /usr/share/nginx/html
Building an Image from the Dockerfile:
   - To build an image from a Dockerfile, you can use the command `docker build -t <image_name> .` in the directory containing the Dockerfile.
   - The `-t` flag allows you to tag the image with a name for easier reference.
   - The `.` at the end specifies the build context, which is the current directory.
   - The command docker build --tag highway:latest . builds the docker image using the Dockerfile in the current directory and tags it as "highway:latest".
   - The resulting image can then be run using the command `docker run -d -p 8080:80 highway:latest`, which starts a new container from the image and maps port 8080 on the host to port 80 in the container.

NodeJS and Express: 
   - Download Nodejs on your local machine from https://nodejs.org/en/download/
   - We will be using nodejs and express to create our web application.
   - Express is a web application framework for Node.js that provides a robust set of features for building web and mobile applications.
   - After installing Nodejs proceed to installing Express at https://expressjs.com/en/starter/installing.html
   - Follow the instructions on the website to install Express using npm (Node Package Manager).
   - Created a directory called UserService-api and installed nodejs on my wsl 
   - once done I proceeded to the directory and installed express using npm install express
   - To install nodejs on ubuntu you can use the following commands:
     ```
     sudo apt update
     sudo apt install nodejs
     sudo apt install npm
     ```
     - This will install Node.js and npm (Node Package Manager) on your Ubuntu system.
     - To verify the installation, you can run the following commands:
       ```
       node -v or node --version
       npm -v
       ```
       - These commands will display the installed versions of Node.js and npm, respectively.
       - to initialize a new Node.js project, you can use the command `npm init` and follow the prompts to create a package.json file.
       - The command npm install --save express will install Express and add it as a dependency in your package.json file.
       - copy the code from https://expressjs.com/en/starter/hello-world.html and paste it in an index.js file
       - once done run the command `node index.js` to start your Express application.
Dockerfile for Node App:
   FROM node:latest
   WORKDIR /app
   ADD . .
   RUN npm install
   CMD node index.js
   - This Dockerfile sets up a container for a Node.js application by using the official Node.js image, copying the application code into the container, installing dependencies, and specifying the command to run the application.
   - The `WORKDIR` instruction sets the working directory inside the container to `/app`.
   - The `ADD` instruction copies the application code from the host machine into the container.
   - The `RUN` instruction installs the application dependencies specified in the package.json file.
   - The `CMD` instruction specifies the command to run the application when the container starts.
   - the difference between RUN and CMD is that RUN is used to build the image and execute commands during the image creation process, while CMD is used to specify the default command to run when a container is started from the image.
   - The `RUN` instruction is executed during the image build process, while the `CMD` instruction is executed when a container is started from the image.
   - Run this command to let create the application on nodejs docker run -d -p 3000:3000 --name nodejs nodejs:latest
   - Node.js applications typically listen on a specific port for incoming requests. In this case, the application is listening on port 3000.
.Dockerignore:
   - When writing dockerfiles, it's important to include a .dockerignore file to exclude unnecessary files and directories from the build context.
   - This can help reduce the size of the image and improve build performance.
   - Common patterns to include in .dockerignore files are:
     ```
     node_modules
     npm-debug.log
     Dockerfile
     .dockerignore
     ```
   - By excluding these files and directories, you can ensure that only the necessary files are included in the build context.
   - The ADD . . adds everything in the current directory to the container's working directory.
   - However, if you have a .dockerignore file, the contents of that file will be used to determine which files and directories to exclude from the build context.
   - This means that any files or directories listed in .dockerignore will not be copied into the container, even if they are present in the current directory.
   - This can be accomplished by creating a .dockerignore file in the root of your project and listing the files and directories to exclude.
Caching and layers:
   - Docker uses a layered filesystem, where each instruction in a Dockerfile creates a new layer in the image.
   - When building an image, Docker caches the layers that have already been built, so that if you make changes to the Dockerfile, only the layers that have changed need to be rebuilt.
   - This can significantly speed up the build process, especially for large images.
   - To take advantage of caching, it's important to order the instructions in your Dockerfile in a way that minimizes the number of layers that need to be rebuilt when changes are made.
   - For example, if you have a RUN instruction that installs dependencies, it's best to place it before any ADD or COPY instructions that add application code to the image.
   - This way, if you make changes to the application code, only the layers that add the code will need to be rebuilt, while the layer that installs dependencies can be reused from the cache.
   - Additionally, you can use multi-stage builds to further optimize your images by separating the build environment from the runtime environment.
   - This allows you to include only the necessary files and dependencies in the final image, reducing its size and improving performance.
   - To use multi-stage builds, you can define multiple FROM instructions in your Dockerfile, each with its own set of instructions.
   - You can then copy files and artifacts from one stage to another using the COPY --from=<stage> instruction.
   - This allows you to create a build stage that includes all the necessary tools and dependencies for building your application, and then copy only the built artifacts into a smaller runtime stage.
   - By using caching and layering effectively in your Dockerfiles, you can create efficient and optimized images that are easy to build and deploy.
   - To take advantage of caching make sure to:
      - Order your Dockerfile instructions from least to most likely to change.
      - Use COPY instead of ADD for adding files, as COPY is more explicit and easier to cache.
      - Leverage build arguments and environment variables to customize your builds without changing the Dockerfile.
      - Add the source code later in the Dockerfile to maximize caching of earlier layers.
      - So adding the source code later in the Dockerfile helps to ensure that changes to the source code do not invalidate the cache for earlier layers, which can significantly speed up the build process.
      - Additionally, you can use the --cache-from option with docker build to specify an existing image to use as a cache source, further improving build times.
      Below is an example of a Docker file that will not use cache:
      ```
      FROM node:14
      WORKDIR /app
      ADD . .
      RUN npm install
      CMD ["npm", "start"]
      ```
      Versus one that will use cache:
      ```
      FROM node:14
      WORKDIR /app
      ADD package*.json ./
      RUN npm install
      ADD . .
      CMD ["npm", "start"]
      ```
Alpine:
      - Linux alpine distribution can be used to reduce the size of the docker image
      - It is a security-oriented, lightweight Linux distribution based on musl libc and busybox.
      - Alpine images are often smaller than their Debian or Ubuntu counterparts, making them a popular choice for microservices and containerized applications.
      - To reduce the size of your Docker images, you can use Alpine-based images as the base image in your Dockerfile.
Pulling Alpine docker images:
      - Almost every docker image out there has an Alpine variant.
      - You can easily find these variants by searching for the image name followed by "-alpine".
      - For example: search for "node-alpine"
   ```
   FROM node:14-alpine
   WORKDIR /app
   ADD package*.json ./
   RUN npm install
   ADD . .
   CMD ["npm", "start"]
   ```
      - To pull an alpine version of an image, you can use the following command:
   ```
   docker pull <image-name>-alpine
   ```
      - For example, to pull the Alpine version of the Node.js image, you would run:
   ```
   docker pull node:14-alpine
   ```
   OR to pull the alpine version of nginx:
   ```
   docker pull nginx:alpine
   ```
   - This pulls the latest Alpine version of the Nginx image.
   - To pull other versions you need to specify the version tag:
   ```
   docker pull <image-name>-alpine:<version>
   ```
Switching to Alpine:
   ```
   FROM node:14-alpine
   WORKDIR /app
   ADD package*.json ./
   RUN npm install
   ADD . .
   CMD ["npm", "start"]
   ```
   - This Dockerfile uses the Alpine version of the Node.js image, which is smaller and more lightweight than the standard version.
   - By switching to Alpine, you can reduce the size of your Docker images and improve the performance of your containerized applications.
   - Additionally, Alpine images often have fewer vulnerabilities and a smaller attack surface, making them a more secure choice for production environments.
   - However, it's important to test your applications thoroughly when switching to Alpine, as some libraries or dependencies may behave differently in the Alpine environment.
Tagging and versioning:
   - Tags and versions allow you to have full control of what images are used in your deployments.
   - By using specific tags, you can ensure that your application is always using the same version of a base image, which can help prevent unexpected issues caused by changes in the base image.
   - It's a good practice to use semantic versioning for your images, so you can easily identify breaking changes and update your deployments accordingly.
   - Always using latest can cause issues because latest is a moving target and can change over time.
   - To avoid these issues, it's recommended to use specific version tags for your images in production environments.
   - This ensures that your application is always using a known, tested version of the base image, reducing the risk of unexpected issues.
   - You need to make sure that your application works correctly with the specific version of the base image you are using.
   - It's also a good idea to regularly update your base images to incorporate security patches and performance improvements.
   - This also helps you have full control over your image versions and reduces the risk of unexpected issues.
   - Regularly updating your base images can help you take advantage of new features and improvements in the underlying operating system and libraries.
   - However, it's important to test your applications thoroughly when updating base images, as changes in the base image can potentially introduce breaking changes or incompatibilities.
Using tags:
   - Tags are labels that you can assign to your Docker images to identify them easily.
   - You can use tags to specify different versions of your images, such as "1.0", "1.1", etc.
   - It's a good practice to use meaningful tags that reflect the purpose or content of the image.
   - You can also use multiple tags for a single image, allowing you to reference the same image with different names or versions.
   - You can get a specific tag on docker hub by searching for the image and selecting the desired tag from the list of available tags.
   - Older tags are still available on Docker Hub, allowing you to roll back to a previous version if needed.
