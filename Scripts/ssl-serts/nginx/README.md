# Генерация ssl сертификатов для nginx

Используем следующую команду 
```
sudo openssl req -new -newkey rsa:2048 -days 365 -nodes -x509 -keyout server.key -out server.crt -subj "/C=RU/ST=Moscow/L=Moscow/O=Rebrain/CN=example.ru" -addext "subjectAltName = DNS:example.ru"
```
В ней указываем свое доменное имя


Создаем файл с именем prometheus в директории /etc/nginx/sites-enabled/

```
server {
    listen              443 ssl;
    server_name         example.com;  # DNS-запись
    ssl_certificate     /etc/prometheus-certs/server.crt;  # путь до сертификата
    ssl_certificate_key /etc/prometheus-certs/server.key;  # путь до ключа

    location / {
        proxy_pass http://localhost:9090/;  # локальный адрес Prometheus
    }
}
```

Проверка корректности конфига nginx

```
sudo nginx -t
```

Перезапускаем nginx

```
sudo systemctl restart nginx
```

