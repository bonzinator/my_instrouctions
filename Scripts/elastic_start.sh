#!/bin/bash

#tarfile=$(date +%d-%m-%Y).tar
current_date=$(date +%Y-%m-%d)

home_path_1=/archiv/logs

guest_path_1=/mnt/logs/logs


log_file=backup.log
share=/mnt/logs

mount $share

mkdir /mnt/logs/logs/logs_backup
touch /mnt/logs/logs/logs_backup/$current_date'_'$log_file


##Создаём новую запись в журнале##
echo "-------------$(date "+%d-%m-%Y")-------------" >> /mnt/logs/logs/logs_backup/$current_date'_'$log_file


tar -czf $guest_path_1/'logs_'$current_date'.tgz' $home_path_1;
echo "$(date "+%d-%m-%Y") Архив 'logs_'$current_date'.tgz' создан в $guest_path_1" >> /mnt/logs/logs/logs_backup/$current_date'_'$log_file;

if [[ -n $(find "$guest_path_1" -type f -name "*$current_date*") ]]; then
    echo "$(date "+%d-%m-%Y") Папка $home_path_1 очищена!" >> /mnt/logs/logs/logs_backup/$current_date'_'$log_file;
    rm -rf "${home_path_1:?}/"*;
else
    echo "$(date "+%d-%m-%Y") Архив $home_path_1 не создан!" >> /mnt/logs/logs/logs_backup/$current_date'_'$log_file;
fi

find /mnt/logs/logs -type f -mtime +365 -delete


umount -l $share