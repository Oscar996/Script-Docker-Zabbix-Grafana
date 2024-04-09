#!/bin/bash
#Script gerado por Oscar Santos

#Atualizar e instalar o Docker
apt-get update -y
apt-get install docker.io -y


#Baixar os containers oficiais
docker pull mysql
docker pull zabbix/zabbix-server-mysql:6.0-ubuntu-latest
docker pull zabbix/zabbix-web-apache-mysql
docker pull zabbix/zabbix-java-gateway
docker pull zabbix/zabbix-agent
docker pull grafana/grafana

#Executar os containers com os parametros pre-configurados
docker run --name mysql-server -t -e MYSQL_DATABASE="zabbix" -e MYSQL_USER="zabbix" -e MYSQL_PASSWORD="pzabbix" -e MYSQL_ROOT_PASSWORD="pzabbix" -d mysql --character-set-server=utf8 --collation-server=utf8_bin --default-authentication-plugin=mysql_native_password
docker run --name zabbix-java-gateway -t --restart unless-stopped -d zabbix/zabbix-java-gateway
docker run --name zabbix-server-mysql -t -e DB_SERVER_HOST="mysql-server" -e MYSQL_DATABASE="zabbix" -e MYSQL_USER="zabbix" -e MYSQL_PASSWORD="pzabbix" -e MYSQL_ROOT_PASSWORD="pzabbix" -e ZBX_JAVAGATEWAY="zabbix-java-gateway" --link mysql-server:mysql --link zabbix-java-gateway:zabbix-java-gateway -p 10051:10051 --restart unless-stopped -d zabbix/zabbix-server-mysql:alpine-6.0-latest
docker run --name zabbix-web-apache-mysql -t -e DB_SERVER_HOST="mysql-server" -e MYSQL_DATABASE="zabbix" -e MYSQL_USER="zabbix" -e MYSQL_PASSWORD="pzabbix" -e MYSQL_ROOT_PASSWORD="pzabbix" --link mysql-server:mysql --link zabbix-server-mysql:zabbix-server -p 80:8080 --restart unless-stopped -d zabbix/zabbix-web-apache-mysql
docker run --name zabbix-agent --link mysql-server:mysql --link zabbix-server-mysql:zabbix-server -e ZBX_HOSTNAME="Zabbix server" -e ZBX_SERVER_HOST="zabbix-server" -d zabbix/zabbix-agent
docker run --name grafana -d -p 3000:3000  -e "GF_INSTALL_PLUGINS=alexanderzobnin-zabbix-app" grafana/grafana

#Rotina de iniciar todos os containers em ordem caso o servidor seja desligado
docker update --restart always mysql-server zabbix-server-mysql zabbix-web-apache-mysql zabbix-java-gateway zabbix-agent grafana

#Endereco IP para ser configurado no host Zabbix Server
echo "Ative o Zabbix Server e configure este endereco IP"
docker inspect zabbix-agent | grep "IPAddress\": "
