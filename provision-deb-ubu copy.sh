#!/bin/bash

#######################################
##  Installeren van Docker (Debian)  ##
#######################################

install_docker_debian() {
    sudo apt update && sudo apt upgrade -y
    sudo apt-get install ca-certificates curl gnupg -y

    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    sudo chmod a+r /etc/apt/keyrings/docker.gpg

    echo \
    "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
    "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    sudo apt-get update

    sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
}

#######################################
##  Installeren van Docker (Ubuntu)  ##
#######################################

install_docker_ubuntu() {
    sudo apt update && sudo apt upgrade -y
    sudo apt-get install ca-certificates curl gnupg -y

    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    sudo chmod a+r /etc/apt/keyrings/docker.gpg

    echo \
    "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
    "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    sudo apt-get update
    sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
}

#######################################
##  Voeg USER toe aan docker groep  ##
#######################################

add_user_to_docker_group() {

}

#######################################
##   Installeren van Portainer       ##
#######################################

install_portainer() {

}

#######################################
##    Script-uitvoering              ##
#######################################

if [[ "$(cat /etc/os-release | grep -w ID | cut -d'=' -f2)" == "debian" ]]; then
    echo "Debian gevonden. Installeren van Docker voor Debian..."
    install_docker_debian
elif [[ "$(cat /etc/os-release | grep -w ID | cut -d'=' -f2)" == "ubuntu" ]]; then
    echo "Ubuntu gevonden. Installeren van Docker voor Ubuntu..."
    install_docker_ubuntu
else
    echo "Distributie niet ondersteund."
    exit 1
fi

sudo groupadd docker
sudo usermod -aG docker $USER
newgrp docker
sudo docker volume create portainer_data
sudo docker run -d -p 8000:8000 -p 9000:9000 --name portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce:latest