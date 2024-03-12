# Omeka-S404 in Docker containers. S404 stands for Omeka S version 4.0.4

## Launch the containers using VSCode

- Install [VSCode](https://code.visualstudio.com/) and [docker extensions](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-docker).
- Launch/open VSCode or learn how to use VSCode [here](https://code.visualstudio.com/learn).
- Clone this repository using VSCode. Learn [how to clone and use a GitHub repository in Visual Studio Code](https://docs.microsoft.com/en-us/azure/developer/javascript/how-to/with-visual-studio-code/clone-github-repository?tabs=create-repo-command-palette%2Cinitialize-repo-activity-bar%2Ccreate-branch-command-palette%2Ccommit-changes-command-palette%2Cpush-command-palette).
- Go to VSCode Explorer. You may use "Ctrl + Shift + E" on windows keyboard.
- Option A (If you don't want to build a docker image using the Dockerfile)
    - Right-click "docker-compose.yml" and select "Compose Up". Alternatively, you can use the terminal: ``` docker compose -f "docker-compose.yml" up -d --build ```
- Option B (if you want to build a docker image using the Dockerfile)
    - Right-click on Dockerfile and select "build image". 
    - Enter "omekas404docker:latest" as the image name. Note that this name is used in the docker-compose.yml file.
    - Press enter to build the docker image.
    - Right-click "docker-compose.yml" and select "Compose Up". Alternatively, you can use the terminal: ``` docker compose -f "docker-compose.yml" up -d --build ```
- Go to your browser and type "localhost" for the OmekaS404 instance website or use "localhost:8080" for the phpmyadmin interface to manage MySQL database.

## Launch the containers using command line

Install Docker and Docker-compose on your host (can be a physical or virtual machine). 

Download the file "docker-compose.yml".

From the directory containing the "docker-compose.yml" file:

```
$ docker-compose up -d
```
OR
```
$ sudo docker-compose up -d
```
OR
```
$ docker compose -f "docker-compose.yml" up -d --build
```

This will deploy three Docker containers:

- Container 1: mariadb (mysql) 
- Container 2: phpmyadmin (connected to container 1)
- Container 3: omeka-s404 (connected to container 1)

Some useful themes and modules for Omeka S version 3.2.0 are also added. Additional modules could be installed using the EasyInstall module.

With your browser, go to:

- Omeka-S404: http://hostname
- PhpMyAdmin: http://hostname:8080

At that point, you can start configuring your Omeka-S web portal.

Remarks:

- images will be downloaded automatically from the Docker hub: 67911151/omeka-s404:latest, mariadb:latest, phpmyadmin:latest. You may also choose to build the docker image for Omeka S 404 using the name "omeka-s404:latest" instead of using the image on Docker hub. 
- for the omeka-s container, /var/www/html/files (media files uploaded by the users) and /var/www/html/config/database.ini (configuration file with the credentials for the db) are put in a named volume and will survive the removal of the container. The mariadb container also puts the data (omeka-s db in /var/lib/mysql) in a named volume. Volumes are hosted in the host filesystem (/var/lib/docker/volumes).

To stop the containers:

```
$ docker-compose stop
```
OR
```
$ sudo docker-compose stop
```

To remove the containers:
```
$ docker-compose rm 
```
OR
```
$ sudo docker-compose rm 
```

Remark: this will NOT delete the volumes (omeka and mariadb). If you launch again "sudo docker-compose up -d", the volumes will be re-used.

To login into a container:

```
$ sudo docker container exec -it <container-id-or-name> bash 
```

## Build a new image (optional)

If you want to modify the omeka-s image (by changing the Dockerfile file), you will need to build a new image:

E.g.:

```
$ git clone https://github.com/spatialscientist/omeka-s404-docker.git
$ cd omeka-s404-docker
```

Edit the Dockerfile file.

Once done, build the new Docker image:

```
$ sudo docker image build -t foo/omeka-s404:1.0.1-bar .
$ sudo docker image tag foo/omeka-s:1.0.1-bar foo/omeka-s404:latest
```

Upload the image to your Docker hub repository:

Login in your account (e.g. foo) on hub.docker.com, and create a repository "omeka-s404", then upload your customized image:

```
$ sudo docker login --username=foo
$ sudo docker image push foo/omeka-s404:1.0.1-bar
$ sudo docker image push foo/omeka-s404:latest
```
