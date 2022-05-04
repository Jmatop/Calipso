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
#Instalamos elasticsearch, pero vamos guardando su salida en el fichero prueba.txt
sudo dnf -y install --enablerepo=elasticsearch elasticsearch > prueba.txt
#Reiniciamos el systemd y habilitamos e iniciamos el servicio de elasticsearch 
sudo /bin/systemctl daemon-reload
sudo /bin/systemctl enable elasticsearch.service
sudo systemctl start elasticsearch.service
#Guardamos en una variable la contraseña, haciendo una busqueda en el fichero prueba.txt que es el que contiene la salida de la instalación
pass=$(cat prueba.txt | grep "generated password for the elastic built-in superuser " | awk '{print $11}')
#Lo guardamos en el fichero que va a contener todas las credenciales necesarias para el usuario
echo "password-elastic:" $pass | sudo tee -a config-elastic.txt
#Y eliminamos el fichero que contenia la salida de la instalación
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
#Remplazamos con el comando sed, la linea server.host del fichero de configuracion de kibana, y lo cambiamos a 0.0.0.0 para que tambien se pueda acceder
#de forma remota en la web a kibana.
sudo sed -i 's/#server.host: "localhost"/server.host: "0.0.0.0"/' /etc/kibana/kibana.yml
#Tenemos la opcion de que Elastic luego se encargue de configurar por si mismo kibana, para ello tenemos que crear un token para kibana con el comando: 
#elasticsearch-create-enrollment-token, tambien guardamos la salida de este comando en la variable token
token=$(sudo /usr/share/elasticsearch/bin/elasticsearch-create-enrollment-token -s kibana)
#Ya guardada la variable, lo guardamos en el fichero que es el que contiene lo necesario para luego finalizar la instalación.
echo "Token-kibana:" $token | sudo tee -a config-elastic.txt
#Se reinicia el systemd, e iniciamos y habilitamos kibana.
sudo /bin/systemctl daemon-reload
sudo systemctl start kibana.service
sudo /bin/systemctl enable kibana.service
echo -e "\e[1;32mEsperando Codigo....\e[0m"
sleep 50
codigo=$(journalctl -u kibana.service | grep "code=" | awk '{print $8}')
echo "Code Verification:" $codigo | sudo tee -a config-elastic.txt
sudo systemctl stop firewalld
sudo systemctl disable firewalld

echo -e "\e[1;32m*******************************************"
echo -e "*                                         *"
echo -e "*           Creando el tshark           *"
echo -e "*                                         *"
echo -e "*******************************************\e[0m"
sudo dnf -y install wireshark-cli
echo "#!/bin/bash" | sudo tee -a /home/$USER/tshark.sh
echo "sudo tshark" | sudo tee -a /home/$USER/tshark.sh


echo -e "\e[1;32m*******************************************"
echo -e "*                                         *"
echo -e "*           Creando el servicio           *"
echo -e "*                                         *"
echo -e "*******************************************\e[0m"
echo "[Unit]" | sudo tee -a /etc/systemd/system/tshark.service
echo "Description=Tshark" | sudo tee -a /etc/systemd/system/tshark.service
echo "[Service]" | sudo tee -a /etc/systemd/system/tshark.service
echo "Type=simple" | sudo tee -a /etc/systemd/system/tshark.service
echo "ExecStart=/home/$USER/tshark.sh" | sudo tee -a /etc/systemd/system/tshark.service
echo "[Install]" | sudo tee -a /etc/systemd/system/tshark.service
echo "WantedBy=multi-user.target" | sudo tee -a /etc/systemd/system/tshark.service

sudo setenforce 0
#sudo ausearch -c 'tshark' --raw | audit2allow -M mi-tshark
#sudo semodule -X 300 -i mi-tshark.pp
sudo systemctl daemon-reload
sudo systemctl start tshark.service

echo -e "\e[1;32m*******************************************"
echo -e "*                                         *"
echo -e "*           Creando lectores              *"
echo -e "*                                         *"
echo -e "*******************************************\e[0m"
echo "#!/bin/bash" | sudo tee -a /home/$USER/.lector.sh
echo "journalctl -u tshark.service | grep -c ICMP > /home/$USER/salidaICMP.data" | sudo tee -a /home/$USER/.lector.sh
echo "journalctl -u tshark.service | grep -c DHCP > /home/$USER/salidaDHCP.data" | sudo tee -a /home/$USER/.lector.sh
echo "journalctl -u tshark.service | grep -c HTTP > /home/$USER/salidaHTTP.data" | sudo tee -a /home/$USER/.lector.sh
echo "journalctl -u tshark.service | grep -c [S]  > /home/$USER/salidaTCP.data" | sudo tee -a /home/$USER/.lector.sh
echo "journalctl -u tshark.service | grep -c UDP  > /home/$USER/salidaUDP.data" | sudo tee -a /home/$USER/.lector.sh
echo "journalctl -u tshark.service | grep -c ARP  > /home/$USER/salidaARP.data" | sudo tee -a /home/$USER/.lector.sh
echo "#Fluenbit" | sudo tee -a /home/$USER/.lector.sh
echo "#rm /home/$USER/salida*" | sudo tee -a /home/$USER/.lector.sh



echo -e "\e[1;32m Ya está todo Instalado, para acabar de configurar Kibana, vaya a: Ip_Màquina:5601\e[0m"

