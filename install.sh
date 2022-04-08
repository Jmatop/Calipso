#!/bin/bash


echo "$(tput setaf 6)Actualizamos librerias "
sleep 3
tput reset
sudo apt update



echo "$(tput setaf 4)Instalamos Suricata"
sleep 3
tput reset
sudo add-apt-repository ppa:oisf/suricata-stable 
sudo apt install --yes software-properties-common
sudo apt install --yes suricata


echo "$(tput setaf 5)Habilitamos Suricata"
sleep 3
tput reset
sudo systemctl enable suricata.service
sudo suricata-update


echo "$(tput setaf 6)Instalamos servidor Apache"
sleep 3
tput reset
sudo apt install --yes apache2


echo "$(tput setaf 2)Instalamos las dependencias para Yara"
sleep 3
tput reset
sudo apt-get install -y automake libtool make gcc flex bison libssl-dev libjansson-dev libmagic-dev
sudo apt-get install -y checkinstall
sudo checkinstall -y --deldoc=yes
sudo apt-get install -y pip
sudo apt install -y yara
git clone https://github.com/Yara-Rules/rules.git
#Para ejecutar las reglas Yara el comando que se usa es:
#yara -f /home/rules/index.yar /home/calipso/


echo "$(tput setaf 3)Instalamos el IP Tracer"
sleep 3
tput reset
git clone https://github.com/rajkumardusad/IP-Tracer.git
cd IP-Tracer
chmod +x install
./install
cd $HOME
#Ejemplo comandos IP Tracer:
#trace -t dirección ip

echo "$(tput setaf 3)Instalación Podman"
sleep 3
tput reset
sudo apt update -y
source /etc/os-release
sudo sh -c "echo 'deb http://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/xUbuntu_${VERSION_ID}/ /' > /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list"
wget -nv https://download.opensuse.org/repositories/devel:kubic:libcontainers:stable/xUbuntu_${VERSION_ID}/Release.key -O- | sudo apt-key add -
sudo apt update -qq
sudo apt-get -qq --yes install podman
sudo systemctl start podman
sudo systemctl enable podman
sudo systemctl stop ufw 
sudo systemctl disable ufw



echo "$(tput setaf 2)Configuración OpenSearch"
sleep 3
tput reset
podman pod create -n miOS -p 9200:9200 -p 9600:9600 -p 5601:5601
podman container create --pod=miOS -e "discovery.type=single-node" opensearchproject/opensearch:latest
podman container create --pod=miOS -e "opensearch.username=admin" -e "opensearch.password=admin" -e "opensearch.ssl.verificationMode=none" opensearchproject/opensearch-dashboards:latest
podman pod start miOS
echo  "$(tput setaf 5) $(tput setab 10)Done."
sleep 10
tput reset
clear
