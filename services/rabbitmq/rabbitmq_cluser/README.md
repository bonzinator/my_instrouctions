В файл `.erlang.cookie` записать ключ для подключения к rabbitmq (ключ может быть любой)

В файл конфигурации `/etc/rabbitmq/rabbitmq.config` добавить необходимое количество хостов

```
cluster_formation.classic_config.nodes.1 = rabbit@host1
cluster_formation.classic_config.nodes.2 = rabbit@host2
```

`host1` и `host2` - названия хостов, которые будут включены в кластер (Указываются в docker-compose.yml параметром `hostname`)



Если контейнеры находятся на разных узлах необходимо провести следующие настройки 

В файле `docker-compose.yml` добавить параметр `extra_hosts` для каждого сервиса в кластере:

```
    extra_hosts:
      host1: 51.250.46.8       # IP адрес хоста host1
      host2: 51.250.42.235     # IP адрес хоста host2
```

Для запуска кластера выполнить команду:

```
docker-compose up -d --build
```