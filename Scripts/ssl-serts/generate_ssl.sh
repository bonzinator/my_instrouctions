#!/bin/bash

# В секции CN и DNS указываем нужные имена домена.

sudo openssl req -new -newkey rsa:2048 -days 365 -nodes -x509 -keyout server.key -out server.crt -subj "/C=RU/ST=Moscow/L=Moscow/O=Rebrain/CN=example.ru" -addext "subjectAltName = DNS:example.ru"
cat server.crt server.key > server.pem

# После этого файл server.pem можно использовать в nginx.conf или haproxy.cfg

