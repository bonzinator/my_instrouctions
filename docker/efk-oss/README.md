# Сборка системы мониторинга логов на основе EFK (OpenSearch)

## Конфигурация Fluentd

Добавляем Dockerfile, где указываем установку плагина Opensearch. 

```
FROM ghcr.io/calyptia/fluentd:v1.14.6-debian-1.0
USER root

RUN gem install fluent-plugin-opensearch
RUN fluent-gem install fluent-plugin-rewrite-tag-filter fluent-plugin-multi-format-parser

USER fluent
```


Создаем по пути ./fluentd/conf файл fluentd.conf и прописываем в него параметры подключения к OpenSearch.

```
# fluentd/conf/fluent.conf

<source>
  @type forward
  port 24224
  bind 0.0.0.0
  body_size_limit 10m
</source>

<match *.**>
  @type copy

  <store>
    @type opensearch
    host opensearch
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

<system>
  <log>
    format json
    time_format %Y-%m-%d
    rotate_age 5
    rotate_size 10485760
  </log>
</system>
```

Обращаем внимаение на подключение к OpenSearch.

```
  <store>
    @type opensearch
    host opensearch
```


## Конфигурация OSD

В конревой директории создаем директорию osd и в ней Dockerfile.

```
FROM opensearchproject/opensearch-dashboards:2.11.1
RUN /usr/share/opensearch-dashboards/bin/opensearch-dashboards-plugin remove securityDashboards
COPY --chown=opensearch-dashboards:opensearch-dashboards opensearch_dashboards.yml /usr/share/opensearch-dashboards/config/
```
В этом файле отключаем поддержку OpenSearch Security.


Создаем файл конфигурации opensearch_dashboards.yml, в который передаем параметры подключения к OpenSearch.

```
server.name: opensearch-dashboards
server.host: "0.0.0.0"
opensearch.hosts: http://localhost:9200
```


## docker-compose.yml стека EFK

```
version: "3"
services:
  fluentd:
    build: ./fluentd
    restart: unless-stopped
    environment:
      - FLUENTD_CONF=fluentd.conf                 # Указываем файл конфиграции fluentd
      - "host=rbmdkrfinalefk-opensearch-1"        # Указываем имя контейнера OpenSearch
    depends_on:
      - opensearch
    volumes:
      - ./fluentd/conf:/fluentd/etc
    networks:
      - network
    links:
      - "opensearch"
    ports:
      - "24224:24224"
      - "24224:24224/udp"


  opensearch:
    image: opensearchproject/opensearch:latest
    restart: unless-stopped
    environment:
      - "discovery.type=single-node"                # Указываем тип обнаружения
      - "plugins.security.disabled=true"            # Отключаем поддержку OpenSearch Security
      - "OPENSEARCH_JAVA_OPTS=-Xms1024m -Xmx1024m"  # Указываем минимальный и максимальный размер памяти
    expose:
      - "9200"
    ports:
      - "9200:9200"
      - "9600:9600"
    networks:
      - network

  osd:
    build: ./osd
    restart: unless-stopped
    environment:
      NODE_OPTIONS: '--max-old-space-size=512'                          # Указываем максимальный размер памяти
      OPENSEARCH_HOSTS: '["http://rbmdkrfinalefk-opensearch-1:9200"]'   # Указываем имя контейнера OpenSearch
    depends_on:
      - opensearch
      - fluentd
    links:
      - "opensearch"
    ports:
      - "5601:5601"
    networks:
      - network
    logging:
      driver: "fluentd"
      options:
        fluentd-address: localhost:24224

networks:
  network:
    external: true
```

Запускаем стек командой 

```
docker-compose up -d --build
```