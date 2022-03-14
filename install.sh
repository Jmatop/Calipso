#!/bin/bash

#Actualizamos librerias
sudo apt update

#Instalamos Suricata
sudo add-apt-repository ppa:oisf/suricata-stable && sudo apt install --yes surica>

#sudo apt install --yes software-properties-common
#sudo apt install --yes suricata

#Habilitamos Suricata
sudo systemctl enable suricata.service
sudo suricata-update

