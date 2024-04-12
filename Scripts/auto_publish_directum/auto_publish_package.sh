#! /bin/bash

# Количество плеч с DirectumRX
COUNT_DRX=4

# IP серверов с сервисам DirectumRX
APP_IP_1=1.1.1.1
APP_IP_2=2.2.2.2
APP_IP_3=3.3.3.3
APP_IP_4=4.4.4.4

# Пользователи
APP_USER_1=root
APP_USER_2=root
APP_USER_3=root
APP_USER_4=root

# Путь к файлу do.sh на серверах 1-4
APP_PATH_1=/srv/drx/do.sh
APP_PATH_2=/srv/drx/do.sh
APP_PATH_3=/srv/drx/do.sh
APP_PATH_4=/srv/drx/do.sh






# Установка ssh соединения, без первичного подтверждения подключения (yes/no)
ssh -o StrictHostKeyChecking=no -l "$APP_USER_1" "$APP_IP_1"

# Выполнение команды на другом сервере при помощи подключения по ssh
ssh root@www 'ps -ef | grep apache | grep -v grep | wc -l'