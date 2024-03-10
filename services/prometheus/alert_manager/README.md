Установка Alertmanager

```
wget https://github.com/prometheus/alertmanager/releases/download/v0.22.2/alertmanager-0.22.2.linux-amd64.tar.gz
tar xf alertmanager-0.22.2.linux-amd64.tar.gz
cd alertmanager-0.22.2.linux-amd64
sudo cp alertmanager /usr/local/bin
sudo mkdir /etc/alertmanager /var/lib/alertmanager
sudo cp alertmanager.yml /etc/alertmanager
sudo useradd --no-create-home --home-dir / --shell /bin/false alertmanager
sudo chown -R alertmanager:alertmanager /var/lib/alertmanager
```

Создание файла для systemd
```
sudo nano /etc/systemd/system/alertmanager.service
```

Добавить в файл:
```
[Unit]
Description=Alertmanager for prometheus
After=network.target
[Service]
User=alertmanager
ExecStart=/usr/local/bin/alertmanager \
--config.file=/etc/alertmanager/alertmanager.yml \
--storage.path=/var/lib/alertmanager/
ExecReload=/bin/kill -HUP $MAINPID
NoNewPrivileges=true
ProtectHome=true
ProtectSystem=full
[Install]
WantedBy=multi-user.target
```

Перезапустить systemd и проверить статус:
```
sudo systemctl daemon-reload
sudo systemctl start alertmanager
sudo systemctl status alertmanager
curl -s http://localhost:9093
```

Добавить в prometheus.yml следущий конфиг:

```
global:
scrape_interval:     15s
evaluation_interval: 15s
# Alertmanager configuration
alerting:
alertmanagers:
- static_configs:
   - targets:
      - localhost:9093
        scrape_configs:
- job_name: 'node'
  static_configs:
   - targets:
      - localhost:9100
```

Перезапускаем prometheus

```
systemctl restart prometheus
```