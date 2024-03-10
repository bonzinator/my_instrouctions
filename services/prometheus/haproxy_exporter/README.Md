Добавим секцию со статистикой в файл конфигурации haproxy.cfg:

```
listen stat
    bind *:777
    mode http
    stats enable
    stats show-legends
    stats refresh 30s
    stats uri /stats
    stats auth admin:admin
    stats hide-version
    stats realm Haproxy\ Statistics
```

Присвоим значение переменной в конфиге syslog:

```
$ vim /etc/sysconfig/rsyslog:
SYSLOGD_OPTIONS="-c 2 -r“
```


Редактируем файл syslog, раскомментируем строчки с параметрами:

```
$ vim /etc/rsyslog.conf:
# Provides UDP syslog reception
$ModLoad imudp
$UDPServerRun 514
# Provides TCP syslog reception
$ModLoad imtcp
$InputTCPServerRun 514
```


Для того, чтобы получать логи в формате JSON, добавим следующие правки.

```
$ vim /etc/rsyslog.conf:
$template haproxy-json,"%msg%\n“
:msg, contains, "{\"type\": \"haproxy\"" /var/log/haproxy.json;haproxy-json
local2.* /var/log/haproxy.log
```


Добавляем набор конфигураций в сам HAProxy

```
$ vim /etc/haproxy/haproxy.cfg:
log         /var/log/haproxy  local2 debug
log         127.0.0.1 local2
```

```
$ vim /etc/haproxy/haproxy.cfg:
log-format              {\"type\":\ \"haproxy\",\"client_ip\":\ \"%ci\",\"client_port\":\ \"%cp\",\"request_date\":\ \"[%t]\",\"frontend_name\":\ \"%f\",\"backend_name\":\ \"%b\",\"server_name\":\ \"%s\",\"http_status_code\":\ \"%ST\",\"bytes_read\":\ \"%B\",\"termination_state\":\ \"%ts\",\"actconn\":\ \"%ac\",\"feconn\":\ \"%fc\",\"beconn\":\ \"%bc\",\"srv_conn\":\ \"%sc\",\"retries\":\ \"%rc\",\"server_queue/backend_queue\":\ \"%sq/%bq\",\"http_method\":\ \"%HM\",\"http_request_and_version\":\ \"%HU\ %HV\",\"backend_server_ip\":\ \"%si\",\"backend_server_port\":\ \"%sp\",\"TR\":\ \"%TR\",\"Tw\":\ \"%Tw\",\"Tc\":\ \"%Tc\",\"Tr\":\ \"%Tr\",\"Ta\":\ \"%Ta\"}
```


Настроим logrotate с конфигурацией разделения логов по дням

```
$ vim /etc/logrotate.conf:
/var/log/haproxy.log
{
    daily
    rotate 30
    missingok
    notifempty
    compress
    sharedscripts
    postrotate
    /bin/kill -HUP `cat /var/run/syslogd.pid 2> /dev/null` 2> /dev/null || true
    /bin/kill -HUP `cat /var/run/rsyslogd.pid 2> /dev/null` 2> /dev/null || true
    endscript
}
/var/log/haproxy.json {
    daily
    rotate 7
    missingok
    notifempty
    compress
    sharedscripts
    postrotate
    /bin/kill -HUP `cat /var/run/syslogd.pid 2> /dev/null` 2> /dev/null || true
    /bin/kill -HUP `cat /var/run/rsyslogd.pid 2> /dev/null` 2> /dev/null || true
    endscript
}
$ haproxy -c -f /etc/haproxy/haproxy.cfg
```


Перезапустим службы для применения конфигурации `systemctl restart rsyslog haproxy`

## Настройка Haproxy exporter

Установка exporter:

```
wget https://github.com/prometheus/haproxy_exporter/releases/download/v0.8.0/haproxy_exporter-0.8.0.linux-amd64.tar.gz
tar -xzf haproxy_exporter-0.8.0.linux-amd64.tar.gz
cd haproxy_exporter-0.8.0.linux-amd64
sudo cp haproxy_exporter /usr/bin/
```
```
sudo nano /etc/systemd/system/haproxy_exporter.service
```

```
[Unit]
Description=Haproxy_exporter
Wants=network-online.target
After=network-online.target
[Service]
Type=simple
User=haproxy
Group=haproxy
Restart=on-failure
ExecReload=/bin/kill -HUP $MAINPID
ExecStart=/usr/bin/haproxy_exporter \
--haproxy.scrape-uri=http://admin:admin@localhost:777/stats;csv \
--web.listen-address=0.0.0.0:9091
SyslogIdentifier=haproxy_exporter
Restart=always
[Install]
WantedBy=multi-user.target
```

```
sudo systemctl daemon-reload
sudo systemctl start haproxy_exporter.service
sudo systemctl status haproxy_exporter.service
```

Добавляем секцию в конфигурацию Prometheus

```
- job_name: 'haproxy'
  static_configs:
   - targets: ['localhost:9091’]
```

Перезагружаем prometheus `systemctl restart prometheus`

Подключаем prometheus к Grafana `http://<ip>:3000`
- Логинимся с помощью логина admin/admin
- Добавляем новый источник данных - Prometheus
- Переходим в раздел "Data Sources"
- Вводим название и IP адрес Prometheus
- Проверяем подключение и сохраняем
- Переходим в раздел "Dashboards"
- Выбираем "Import"
- Выбираем "Upload.json File"
- Выбираем файл с дашбордом

Ссылка для скачивания дашборда: [https://grafana.com/api/dashboards/2428/revisions/7/download](https://grafana.com/api/dashboards/2428/revisions/7/download)

