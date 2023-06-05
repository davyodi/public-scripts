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
    sudo apt -y remove needrestart
    sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
    # Zorgt ervoor dat het een docker swarm omging zal worden!
    sudo docker swarm init
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
    sudo apt -y remove needrestart
    sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
    # Zorgt ervoor dat het een docker swarm omging zal worden!
    sudo docker swarm init
}

#######################################
##    Bepalen welke docker versie    ##
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

#######################################
##  Voeg USER toe aan docker groep   ##
#######################################

sudo groupadd docker
sudo usermod -aG docker $USER
newgrp docker

#######################################
##  Mounten van de USB-Stick         ##
#######################################

# Controleer of de /mnt/usb directory bestaat
if [ ! -d "/mnt/usb" ]; then
  echo "De /mnt/usb directory bestaat niet. Het wordt aangemaakt..."
  sudo mkdir /mnt/usb
fi

# Zoek het apparaatpad van de USB-stick
device_path=$(sudo fdisk -l | grep -o '/dev/sd[a-z][0-9]*')

# Controleer of er een USB-apparaat is gevonden
if [ -z "$device_path" ]; then
  echo "Geen USB-apparaat gevonden."
  exit 1
fi

# Controleer of het apparaat al is opgenomen in /etc/fstab
grep -q "$device_path" /etc/fstab
if [ $? -eq 0 ]; then
  echo "Het apparaat is al opgenomen in /etc/fstab."
else
  # Maak een back-up van /etc/fstab
  sudo cp /etc/fstab /etc/fstab.bak

  # Voeg een regel toe aan /etc/fstab om de USB-stick te mounten
  echo "$device_path  /mnt/usb  auto  defaults  0  0" | sudo tee -a /etc/fstab

  # Mount de USB-stick
  sudo mount -a

  # Controleer of het mounten succesvol was
  if [ $? -eq 0 ]; then
    echo "De USB-stick is succesvol gemount op /mnt/usb."
  else
    echo "Er is een fout opgetreden bij het mounten van de USB-stick."
    # Herstel de oorspronkelijke /etc/fstab
    sudo mv /etc/fstab.bak /etc/fstab
  fi
fi

# Controleer of mount bij opstart actief is.
grep -q "sudo mount -a" /etc/rc.local
if [ $? -eq 0 ]; then
  echo "Mounten bij opstart is actief"
else
  # Voeg commando "sudo mount -a"
  sudo sed -i '$d' /etc/rc.local
  echo "sleep 10" | sudo tee -a /etc/rc.local > /dev/null
  echo "sudo mount -a" | sudo tee -a /etc/rc.local > /dev/null
  echo "exit 0" | sudo tee -a /etc/rc.local > /dev/null

#######################################
##  Terug zetten van de appdata      ##
#######################################

#sudo cp -r /mnt/usb/appdata/ /
sudo rsync -av /mnt/usb/appdata/ /appdata/

#######################################
##  Installeren van Portainer        ##
#######################################

sudo docker run -d -p 8000:8000 -p 9000:9000 --name portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v /appdata/portainer:/data portainer/portainer-ee:latest

#######################################
##  Eind Banner na recovery          ##
#######################################

#Gemaakt met https://www.kammerl.de/ascii/AsciiSignature.php

echo " ___   _         ___            _             _ "
echo "| . \ <_>  ___  | . \ _ _  ___ <_> ___  ___ _| |_"
echo "|  _/ | | |___| |  _/| '_>/ . \| |/ ._>/ | ' | | "
echo "|_|   |_|       |_|  |_|  \___/| |\___.\_|_. |_| "
echo "                              <__'  "
echo ""
echo " ___                                      ___                  _ "
echo "| . \ ___  ___  ___  _ _  ___  _ _  _ _  | . \ ___ ._ _  ___  | |"
echo "|   // ._>/ | '/ . \| | |/ ._>| '_>| | | | | |/ . \| ' |/ ._> |_/"
echo "|_\_\\___.\_|_.\___/|__/ \___.|_|  `_. | |___/\___/|_|_|\___. <_>"
echo "                                   <___'                         "
echo "" 