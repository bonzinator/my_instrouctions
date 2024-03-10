# Собираем кластер haproxy и keepalived

## Добавляем в sysctl параметры на всех нодах

```
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1             #этими двумя строками отключаем IPv6
net.ipv4.ip_nonlocal_bind = 1                      #позволяет отдельным локальным процессам выступать от имени внешнего (чужого) IP-адреса
net.ipv4.conf.all.arp_ignore = 1                   #отвечать на ARP-запрос только в том случае, если целевой IP-адрес является локальным,сконфигурированным на входящем интерфейсе
net.ipv4.conf.all.arp_announce = 1                 #избегать локальных адресов, которые отсутствуют в целевой подсети этого интерфейса
net.ipv4.conf.all.arp_filter = 0                   #выключает связывание IP-адреса с ARP-адресом
net.ipv4.conf.<your_interface>.arp_filter = 1      #указываем свой интерфейс, на котором будет работать кластер
```

Применяем параметры

```
sysctl -p
```


## Создаем файлы конфигурации keepalived и haproxy

Примеры файлов лежат в репозитории. Важно отметить, чтоб файл конфигурации haproxy на всех нодах был одинаковый.

Для того чтобы создать файл конфигурации keepalived, нужно выполнить команду:

```
nano /etc/keepalived/keepalived.conf
```

Перезапускаем haproxy и keepalived

```
systemctl start keepalived haproxy && systemctl enable keepalived haproxy
```