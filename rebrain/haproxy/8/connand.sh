#! /bin/bash

apt update && apt install -y keepalived

nano /etc/keepalived/keepalived.conf

sudo openssl req -new -newkey rsa:2048 -days 365 -nodes -x509 -keyout prometheus.key -out prometheus.crt -subj "/C=RU/ST=Moscow/L=Moscow/O=Rebrain/CN=rebrain.ru" -addext "subjectAltName = DNS:rebrain.ru"

cat prometheus.crt prometheus.key > rebrain.pem

cp rebrain.pem /etc/haproxy/



