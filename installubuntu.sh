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
apt install --yes curl

echo -e "\e[1;32m*******************************************"
echo -e "*                                         *"
echo -e "*           Instalación Suricata          *"
echo -e "*                                         *"
echo -e "*******************************************\e[0m"
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
echo -e "\e[1;32m*****************************************************"
echo -e "*                                                   *"
echo -e "*           Creación de Repositorio Kibana          *"
echo -e "*                                                   *"
echo -e "*****************************************************\e[0m"
echo "[kibana-8.x]" | sudo tee -a /etc/yum.repos.d/kibana.repo
echo "name=Kibana repository for 8.x packages" | sudo tee -a /etc/yum.repos.d/kibana.repo
echo "baseurl=https://artifacts.elastic.co/packages/8.x/yum" | sudo tee -a /etc/yum.repos.d/kibana.repo
echo "gpgcheck=1" | sudo tee -a /etc/yum.repos.d/kibana.repo
echo "gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch"| sudo tee -a /etc/yum.repos.d/kibana.repo
echo "enabled=1" | sudo tee -a /etc/yum.repos.d/kibana.repo
echo "autorefresh=1" | sudo tee -a /etc/yum.repos.d/kibana.repo
echo "type=rpm-md" | sudo tee -a /etc/yum.repos.d/kibana.repo

echo -e "\e[1;32m****************************************"
echo -e "*                                      *"
echo -e "*           Instalando Kibana          *"
echo -e "*                                      *"
echo -e "****************************************\e[0m"
sudo apt install-y kibana
echo -e "\e[1;32m*******************************************"
echo -e "*                                         *"
echo -e "*           Configuración Kibana          *"
echo -e "*                                         *"
echo -e "*******************************************\e[0m"
sudo sed -i 's/#server.host: "localhost"/server.host: "0.0.0.0"/' /etc/kibana/kibana.yml
token=$(sudo /usr/share/elasticsearch/bin/elasticsearch-create-enrollment-token -s kibana)
echo "Token-kibana:" $token | sudo tee -a config-elastic.txt
sudo /bin/systemctl daemon-reload
sudo systemctl start kibana.service
sudo /bin/systemctl enable kibana.service
echo -e "\e[1;32mEsperando Codigo....\e[0m"
sleep 50
codigo=$(journalctl -u kibana.service | grep "code=" | awk '{print $8}')
echo "Code Verification:" $codigo | sudo tee -a config-elastic.txt
sudo systemctl stop firewalld
sudo systemctl disable firewalld
echo -e "\e[1;32m Ya está todo Instalado, para acabar de configurar Kibana, vaya a: Ip_Màquina:5601\e[0m"
