#!/bin/bash
red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
blue='\033[0;34m'
magenta='\033[0;35m'
cyan='\033[0;36m'
clear='\033[0m'

$cyan
#Actualizamos librerias
sudo apt update
$clear

$red
#Instalamos Suricata
sudo add-apt-repository ppa:oisf/suricata-stable 
sudo apt install --yes software-properties-common
sudo apt install --yes suricata


#Habilitamos Suricata
#sudo systemctl enable suricata.service
#sudo suricata-update
$clear

$yellow
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
$clear

$green
#Instalamos el IP Tracer
git clone https://github.com/rajkumardusad/IP-Tracer.git
cd IP-Tracer
chmod +x install
./install
#Ejemplo comandos IP Tracer:
#trace -t dirección ip
$clear

