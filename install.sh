#!/bin/bash

#Actualizamos librerias
sudo apt update



#Instalamos Suricata
sudo add-apt-repository ppa:oisf/suricata-stable 
sudo apt install --yes software-properties-common
sudo apt install --yes suricata


#Habilitamos Suricata
#sudo systemctl enable suricata.service
#sudo suricata-update

#Instalamos servidor Apache
sudo apt install --yes apache2

#Instalamos las dependencias para Yara
sudo apt-get install -y automake libtool make gcc flex bison libssl-dev libjansson-dev libmagic-dev
sudo apt-get install -y checkinstall
sudo checkinstall -y --deldoc=yes
sudo apt-get install -y pip
sudo apt install -y yara
git clone https://github.com/Yara-Rules/rules.git
#Para ejecutar las reglas Yara el comando que se usa es:
#yara -f /home/rules/index.yar /home/calipso/

#Instalamos el IP Tracer
git clone https://github.com/rajkumardusad/IP-Tracer.git
cd IP-Tracer
chmod +x install
./install
#Ejemplo comandos IP Tracer:
#trace -t dirección ip

#Instalación OpenSearch
source /etc/os-release
echo "deb https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/xUbuntu_${VERSION_ID}/ /" | sudo tee /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list
curl -L https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/xUbuntu_${VERSION_ID}/Release.key | sudo apt-key add -
apt-get update
sudo apt install -y podman

#Configuración OpenSearch
podman pod create -n miOS -p 9200:9200 -p 9600:9600 -p 5601:5601
podman container create --pod=miOS -e "discovery.type=single-node" opensearchproject/opensearch:latest
podman container create --pod=miOS -e "opensearch.username=admin" -e "opensearch.password=admin" -e "opensearch.ssl.verificationMode=none" opensearchproject/opensearch-dashboards:latest
podman pod start miOS

echo "Ready."
sleep 5 
clear
