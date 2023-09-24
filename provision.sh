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
    sudo groupadd docker
    sudo usermod -aG docker $USER
    newgrp docker
}

#######################################
##   Installeren van Portainer       ##
#######################################

install_portainer() {
    sudo docker volume create portainer_data
    docker run -d -p 8000:8000 -p 9000:9000 --name portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce:latest
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

add_user_to_docker_group
install_portainer

#######################################
##     Banner na provison script     ##
#######################################

#Gemaakt met https://www.kammerl.de/ascii/AsciiSignature.php
echo ""
echt " _____                _     _               _____                     _ "
echt "|  __ \              (_)   (_)             |  __ \                   | |"
echt "| |__) | __ _____   ___ ___ _  ___  _ __   | |  | | ___  _ __   ___  | |"
echt "|  ___/ '__/ _ \ \ / / / __| |/ _ \| '_ \  | |  | |/ _ \| '_ \ / _ \ | |"
echt "| |   | | | (_) \ V /| \__ \ | (_) | | | | | |__| | (_) | | | |  __/ |_|"
echt "|_|   |_|  \___/ \_/ |_|___/_|\___/|_| |_| |_____/ \___/|_| |_|\___| (_)"
echt ""