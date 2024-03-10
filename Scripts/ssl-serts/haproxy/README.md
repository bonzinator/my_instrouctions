# Добавляем ssl сертификаты

В секции `frontend` добавляем: 

```
bind *:443 ssl crt /etc/haproxy/server.pem
```

В секции `global` добавляем:

```
tune.SSL.default-dh-param 2048
```
Если используется ssl по умолчанию с использованием 2048 битного шифрования


Перезагружаем haproxy

```
systemctl restart haproxy
```