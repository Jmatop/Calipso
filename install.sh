#!/bin/bash


echo "
╔═╗┌─┐┬  ┬┌─┐┌─┐┌─┐   
║  ├─┤│  │├─┘└─┐│ │   
╚═╝┴ ┴┴─┘┴┴  └─┘└─┘   
╔═╗┌─┐┌─┐┬ ┬┬─┐┬┌┬┐┬ ┬
╚═╗├┤ │  │ │├┬┘│ │ └┬┘
╚═╝└─┘└─┘└─┘┴└─┴ ┴  ┴                                                        
"
sleep 5

echo "$(tput setaf 6)Actualizamos librerias "
sleep 3
tput reset
sudo apt update

echo -e "\e[1;32m*******************************************"
echo -e "*                                         *"
echo -e "*           Instalación Suricata          *"
echo -e "*                                         *"
echo -e "*******************************************\e[0m"

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

echo -e "\e[1;32m*****************************************"
echo -e "*                                       *"
echo -e "*           Instalación Apache          *"
echo -e "*                                       *"
echo -e "*****************************************\e[0m"
tput reset
sudo apt install --yes apache2


echo -e "\e[1;32m*****************************************"
echo -e "*                                       *"
echo -e "*         Instalación Reglas Yara       *"
echo -e "*                                       *"
echo -e "*****************************************\e[0m"
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


echo -e "\e[1;32m********************************************"
echo -e "*                                          *"
echo -e "*           Instalación IP Tracer          *"
echo -e "*                                          *"
echo -e "********************************************\e[0m"
tput reset
git clone https://github.com/rajkumardusad/IP-Tracer.git
cd IP-Tracer
chmod +x install
./install
cd $HOME
#Ejemplo comandos IP Tracer:
#trace -t dirección ip

echo -e "\e[1;32m***********************************************"
echo -e "*                                             *"
echo -e "*           Instalando ElasticSearch          *"
echo -e "*                                             *"
echo -e "***********************************************\e[0m"
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo gpg --dearmor -o /usr/share/keyrings/elasticsearch-keyring.gpg
sudo apt-get install apt-transport-https
echo "deb [signed-by=/usr/share/keyrings/elasticsearch-keyring.gpg] https://artifacts.elastic.co/packages/8.x/apt stable main" | sudo tee /etc/apt/sources.list.d/elastic-8.x.list
sudo apt-get update && sudo apt-get install elasticsearch > prueba.txt
sudo /bin/systemctl daemon-reload
sudo /bin/systemctl enable elasticsearch.service
sudo systemctl start elasticsearch.service
pass=$(cat prueba.txt | grep "generated password for the elastic built-in superuser " | awk '{print $11}')
echo "password-elastic:" $pass | sudo tee -a config-elastic.txt
rm prueba.txt
sleep 20
sudo curl -s --cacert /etc/elasticsearch/certs/http_ca.crt -k -u elastic:$pass https://localhost:9200 | grep "You Know, for Search"  > /dev/null
funciona=$?
if (( $funciona == 0 )); then
        echo -e "\e[1;32m ElasticSearch funciona correctamente !!!\e[0m"
else
        echo "No funciona"
fi
