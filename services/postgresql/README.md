# Сборка из исходных кодов

Перед началом нужно убедится что установлен компилятор иначе система выдаст ошибку. 


## Инструкция по сборке PostgreSQL


1. Команда запуска конфигурации

```
./configure --prefix=/var/lib/postgresql
```


2. Подготовка пакета к установке с расширениями

```
make world
```

3. Установка `PostgreSQL` полная с расширениями

```
make install-world
```

4. Устанавливаем переменную `PGDATA` и выдаем права пользователя на все файлы директории сервера СУБД

```
export PGDATA=/var/lib/postgresql/main
```

```
chown -R user:user /var/lib/postgresql/
```


5. Инициализируем базу данных

```
/var/lib/postgresql/bin/pg_ctl initdb
```

6. Запускаем сервер баз данных

```
/var/lib/postgresql/bin/pg_ctl -D /var/lib/postgresql/main/ start
```


7. Добавляем файл для демона по пути `/etc/systemd/system/postgresql.service`. 
В параметре `ExecStart` указываем путь к бинарному файлу `postgres` и через ключ -D передаем путь к данным базы. 
Так же указываем пользователя в блоке `User`, которого мы указали в пункте `4`

```
[Unit]
Description=PostgreSQL database server
Documentation=man:postgres(1)
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
User=postgres
ExecStart=/var/lib/postgresql/bin/postgres -D /var/lib/postgresql/main/
ExecReload=/bin/kill -HUP $MAINPID
KillMode=mixed
KillSignal=SIGINT
TimeoutSec=infinity

[Install]
WantedBy=multi-user.target

```


8. Перезагружаем службу systemd и рестартуем postgresql. Возможно потребуется перезагрузка сервера.

```
systemctl daemon-reload
```
```
systemctl restart postgresql && systemctl enable postgresql
```