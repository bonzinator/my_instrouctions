# Создание docker контейнера HAProxy с кастомным портом

Создаем Dockerfile для haproxy 

```
FROM haproxy:2.3
COPY haproxy.cfg /usr/local/etc/haproxy/haproxy.cfg
COPY rebrain.pem /usr/local/etc/haproxy/server.pem
```
В директорию с Dockerfile добавляем сертификат с расширением pem и файл конфигурации haproxy (haproxy.cfg)


Создаем файл docker-compose.yml

```
version: "3"

services:
  rabbitmq:
    build: ./
    container_name: haproxy
    ports:
      - 4443:4443            # Открываем нужные порты
      - 8080:8080            # Используем для статистики
```


Добавляем конфигурацию в haproxy.cfg

```
global
    ssl-default-bind-options ssl-min-ver TLSv1.2
#    log         127.0.0.1 local2
    log stdout local0 debug
    chroot      /var/lib/haproxy
    pidfile     /var/run/haproxy.pid
    maxconn     4000
    user        haproxy
    group       haproxy
    daemon
    # turn on stats unix socket
    stats socket /var/lib/haproxy/stats
#    tune.ssl.default-dh-param 4096 # добавлено 30.08.22

defaults
    mode                       http
    timeout connect            60s
    timeout client             2m
    timeout server             15m
    timeout check              30s
    timeout http-keep-alive    340s
    # option http-server-close  # 30.08.22
    option                     forwardfor except 127.0.0.0/8
    option                     redispatch
    option                     httplog
    option                     http-keep-alive
    default-server init-addr last,libc,none
    retries 3
    maxconn 4000
    # log stdout len 4096 format raw local0 debug
    log                        global
#    compression algo           gzip
#    compression type           text/html application/javascript text/css application/x-javascript text/javascript

frontend directumrx
    bind *:4443
    bind *:4443 ssl crt /usr/local/etc/haproxy/rebrain.pem
    redirect scheme https if !{ ssl_fc }
    http-request set-header X-Forwarded-Proto https
    default_backend rx-nodes

backend rx-nodes
    server rx1 192.168.122.186:443 check ssl verify none maxconn 1000

frontend stats
    bind *:8080
    stats enable
    stats uri /stats
    stats refresh 10s
    stats show-node
    stats auth admin:11111
```


В секции frontend указываем привязки к нашему кастомному порту

```
frontend directumrx
    bind *:4443
    bind *:4443 ssl crt /usr/local/etc/haproxy/rebrain.pem
    redirect scheme https if !{ ssl_fc }
    http-request set-header X-Forwarded-Proto https
    default_backend rx-nodes
```


В секции backend указываем ip адрес сервера, куда хотим отправлять запросы

```
backend rx-nodes
    server rx1 192.168.122.186:443 check ssl verify none maxconn 1000
```


Для того чтобы запустить контейнер, используем следующую команду из директории с файлом docker-compose.yml

```
docker-compose up -d --build
```