Установка node_exporter

```
wget https://github.com/prometheus/node_exporter/releases/download/v1.2.0/node_exporter-1.2.0.linux-amd64.tar.gz
tar xf node_exporter-1.2.0.linux-amd64.tar.gz
cd node_exporter-1.2.0.linux-amd64
sudo cp node_exporter /usr/local/bin
sudo useradd --no-create-home --home-dir / --shell /bin/false node_exporter
```


Создадим systemd unit для node_exporter
```
sudo vim /etc/systemd/system/node_exporter.service
```

Добавим в него следующее:
```
[Unit]
Description=Prometheus Node Exporter
After=network.target
[Service]
Type=simple
User=node_exporter
Group=node_exporter
ExecStart=/usr/local/bin/node_exporter
SyslogIdentifier=node_exporter
Restart=always
PrivateTmp=yes
ProtectHome=yes
NoNewPrivileges=yes
ProtectSystem=strict
ProtectControlGroups=true
ProtectKernelModules=true
ProtectKernelTunables=yes
[Install]
WantedBy=multi-user.target
```

Запусим и проверим работоспособность

```
systemctl daemon-reload
systemctl start node_exporter
systemctl status node_exporter
curl -s http://localhost:9100/metrics
```

Добавим в prometheus.yml секцию node_exporter

```
- job_name: 'node'
  static_configs:
   - targets:
      - localhost:9100
```