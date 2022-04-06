#!/bin/bash

#Configuración OpenSearch
podman pod create -n miOS -p 9200:9200 -p 9600:9600 -p 5601:5601
sleep 20
podman container create --pod=miOS -e "discovery.type=single-node" opensearchproject/opensearch:latest
sleep 20
podman container create --pod=miOS -e "opensearch.username=admin" -e "opensearch.password=admin" -e "opensearch.ssl.verificationMode=none" opensearchproject/opensearch-dashboards:latest
sleep 20
podman pod start miOS
echo "Done."
sleep 10
