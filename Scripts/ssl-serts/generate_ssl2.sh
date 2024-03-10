#!/bin/bash

#генерируем открытый ключ
openSSL genrsa -out rebrian.key 2048 

#на базе открытого ключа создаём сертификат с использования типом шифрования sha256 и сроком 1024 дней
openSSL req -x509 -new -nodes -key rebrian.key -sha256 -days 1024 -out server.pem 

# После этого файл server.pem можно использовать в nginx.conf или haproxy.cfg