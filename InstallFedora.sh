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
echo -e "\e[1;32m*******************************************"
echo -e "*                                         *"
echo -e "*           Instalación Suricata          *"
echo -e "*                                         *"
echo -e "*******************************************\e[0m"
sudo dnf -y install suricata && sudo sed -i "s|eth0|enp0s3|" /etc/sysconfig/suricata
sudo systemctl start suricata
sudo systemctl enable suricata

echo -e "\e[1;32m*****************************************"
echo -e "*                                       *"
echo -e "*           Instalación Apache          *"
echo -e "*                                       *"
echo -e "*****************************************\e[0m"
sudo dnf -y install httpd

echo -e "\e[1;32m********************************************"
echo -e "*                                          *"
echo -e "*           Instalación IP Tracer          *"
echo -e "*                                          *"
echo -e "********************************************\e[0m"
git clone https://github.com/rajkumardusad/IP-Tracer.git
cd IP-Tracer
chmod +x install
./install
cd $HOME

echo -e "\e[1;32m***************************************"
echo -e "*                                     *"
echo -e "*           Instalación Java          *"
echo -e "*                                     *"
echo -e "***************************************\e[0m"
sudo dnf -y install java-11-openjdk

echo -e "\e[1;32m************************************************************"
echo -e "*                                                          *"
echo -e "*           Creación de Repositorio ElasticSearch          *"
echo -e "*                                                          *"
echo -e "************************************************************\e[0m"
sudo rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch
echo "[elasticsearch]" | sudo tee -a /etc/yum.repos.d/elasticsearch.repo
echo "name=Elasticsearch repository for 8.x packages" | sudo tee -a /etc/yum.repos.d/elasticsearch.repo
echo "baseurl=https://artifacts.elastic.co/packages/8.x/yum" | sudo tee -a /etc/yum.repos.d/elasticsearch.repo
echo "gpgcheck=1" | sudo tee -a /etc/yum.repos.d/elasticsearch.repo
echo "gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch"| sudo tee -a /etc/yum.repos.d/elasticsearch.repo
echo "enabled=0" | sudo tee -a /etc/yum.repos.d/elasticsearch.repo
echo "autorefresh=1" | sudo tee -a /etc/yum.repos.d/elasticsearch.repo
echo "type=rpm-md" | sudo tee -a /etc/yum.repos.d/elasticsearch.repo
echo -e "\e[1;32m***********************************************"
echo -e "*                                             *"
echo -e "*           Instalando ElasticSearch          *"
echo -e "*                                             *"
echo -e "***********************************************\e[0m"
sudo dnf -y install --enablerepo=elasticsearch elasticsearch > prueba.txt
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
sudo dnf -y install kibana
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
echo -e "\e[1;32m Una vez alli, hay que mirar el fichero ~/config-elastic.txt, Donde se encontrara la información para acabar de configurar kibana\e[0m"