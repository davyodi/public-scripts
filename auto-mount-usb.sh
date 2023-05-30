!/bin/bash

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
  echo "sleep 10" | sudo tee -a /etc/rc.local
  echo "sudo mount -a" | sudo tee -a /etc/rc.local
  echo "exit 0" | sudo tee -a /etc/rc.local
