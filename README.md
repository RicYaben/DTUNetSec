# 02233 - Network Security (2025)

Here you can find a `docker-compose` file to start all the required services and applications we are going to use throughout the Network Security course and its laboratory exercises.

First, compose up the containers.

For the kali environment, open `https://localhost:6901/` in your browser, and continue with credentials:

```sh
User : kasm_user
Password: password
```

To use `bloodhound`, you have to start the `neo4j` service:

```sh
sudo neo4j start
```

## Linux

### Integrate docker's apt repository

```sh
sudo apt update && sudo apt upgrade
sudo apt install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
```

### Install docker

```sh
sudo apt update && sudo apt upgrade
sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

### Test docker installation

```sh
docker --version
sudo docker run hello-world
```

### Install git

```sh
sudo apt install git
```

### Test git installation

```sh
git --version
```

### Clone GitHub repository

```sh
git clone https://github.com/RicYaben/DTUNetSec.git
```

### Build and start docker containers

```sh
sudo docker compose up -d --build
```

### Access Kali Linux (Docker)

For the Kali environment, open `https://localhost:6901/` in your browser, and continue with credentials:

User : `kasm_user`

Password: `password`

### Uninstall docker
To completely remove docker from your system (don't do if you want to run kali), run the following commands:
```sh
dkg -l | grep -i docker
sudo apt purge docker-buildx-plugin docker-ce docker-ce-cli docker-compose-plugin containerd.io
ls /var/lib/docker
sudo rm -rf /var/lib/docker
cat /etc/group | grep docker
sudo groupdel docker
docker --version
```

### Additional docker commands
To display the manual or help options for Docker:
```sh
man docker
```
```sh
docker --help
```
To list all Docker images available on your system:
```sh
docker images
```
To list active and inactive containers:
```sh
docker ps
```
```sh
docker ps -a
```
To see available `docker compose` options (specified in .yml file):
```sh
docker compose --help
```
To manage running containers:
```sh
docker compose stop
```
```sh
docker compose start
```
To clean up and remove unused containers:
```sh
docker compose rm
```
```sh
docker compose down --rmi local 
```
To manage specific containers from the system:
```sh
sudo docker rmi <name>
```
```sh
docker stop <name>
```
```sh
docker rm <name>
```
```sh
docker rmi <name>
```
