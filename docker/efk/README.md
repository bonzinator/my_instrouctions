# Сборка стека EFK


Напишем файл Dockerfile и положим его вместе с docker-compose.yml

```
FROM fluent/fluentd:v1.12.0-debian-1.0
USER root
RUN gem uninstall -I elasticsearch && gem install elasticsearch -v 7.17.0
RUN ["gem", "install", "fluent-plugin-elasticsearch", "--no-document", "--version", "5.0.3"]
USER fluent
```


Следующим шагом добавим docker-compose.yml

```
version: "3"
services:
  fluentd:
    build: ./fluentd
    environment:
      - FLUENTD_CONF=fluentd.conf
    depends_on:
      - elasticsearch
    volumes:
      - ./fluentd/conf:/fluentd/etc
    links:
      - "elasticsearch"
    ports:
      - "24224:24224"
      - "24224:24224/udp"
  elasticsearch:
    image: elasticsearch:7.13.1
    container_name: elasticsearch
    environment:
      - discovery.type=single-node
      - xpack.security.enabled=false
      - "ES_JAVA_OPTS=-Xms1024m -Xmx1024m"
    expose:
      - 9200
    ports:
      - "9200:9200"
      - "9300:9300"
  kibana:
    image: kibana:7.13.1
    environment:
      NODE_OPTIONS: '--max-old-space-size=512'
    depends_on:
      - elasticsearch
      - fluentd
    links:
      - "elasticsearch"
    ports:
      - "5601:5601"
    logging:
      driver: "fluentd"
      options:
        fluentd-address: localhost:24224
```


Данная директива docker-compose обеспечивает сбор логов с docker контейнеров и отправляет их в elasticsearch.

```
    logging:
      driver: "fluentd"
      options:
        fluentd-address: localhost:24224
```

Создадим директорию ./fluentd и добавим туда файл fluentd.conf

```
mkdir -p ./fluentd/conf

nano ./fluentd/conf/fluentd.conf
```

Добавим в него следующее содержимое

```
# fluentd/conf/fluent.conf
<source>
  @type forward
  port 24224
  bind 0.0.0.0
</source>
<match *.**>
  @type copy
  <store>
    @type elasticsearch
    host elasticsearch
    port 9200
    logstash_format true
    logstash_prefix fluentd
    logstash_dateformat %Y%m%d
    include_tag_key true
    type_name access_log
    tag_key @log_name
    flush_interval 1s
  </store>
  <store>
    @type stdout
  </store>
</match>
```


Для создания контейнеров используем следующую команду

```
docker-compose up -d --build
```