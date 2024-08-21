#!/bin/bash

# Классификация введенного символа

if [ $# -ne 1 ]; then

    echo "Неверное количество аргументов"
    exit 1

fi

# Проверка, был ли введен один символ 

char=$1

case $char 
in
    [a-z]) echo "Это маленькая буква";;
    [A-Z]) echo "Это большая буква";;
    [0-9]) echo "Это цифра";;
    ?    ) echo "Это не буква, цифра или пробел";;
    *    ) echo "Пожалуйста, введите один символ";;

esac
