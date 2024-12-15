#! /bin/bash

step=$1

if [ $step == 'up' ]; then
    
    echo "Создаем сеть и запускаем контейнеры"
    docker network create --driver bridge network
    docker-compose -f efk.compose.yml -p rbmdkrfinalefk up -d --build
    sleep 10
    docker-compose -f app.compose.yml -p rbmdkrfinalapp up -d --build

elif [ $step == 'down' ]; then

    echo "Останавливаем и удаляем контейнеры"
    docker-compose -f app.compose.yml -p rbmdkrfinalapp down
    sleep 10
    docker-compose -f efk.compose.yml -p rbmdkrfinalefk down
    docker network rm network

else
    
    echo "Неизвестный параметр. Вы можете использовать 'up' или 'down'"
    exit 1

fi
