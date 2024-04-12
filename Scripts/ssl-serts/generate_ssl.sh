#!/bin/bash

# В секции CN и DNS указываем нужные имена домена.

sudo openssl req -new -newkey rsa:2048 -days 365 -nodes -x509 -keyout server.key -out server.crt -subj "/C=RU/ST=Moscow/L=Moscow/O=Rebrain/OU=Rebrain/CN=example.ru" -addext "subjectAltName = DNS:example.ru"
cat server.crt server.key > server.pem

# После этого файл server.pem можно использовать в nginx.conf или haproxy.cfg



openssl genrsa -out tls.key 2048

openssl req -new -x509 -key tls.key -out tls.cert -days 360 -subj /CN=kubia.example.com