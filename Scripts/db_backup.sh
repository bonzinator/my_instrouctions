#!/bin/bash

POSTGRES_DB=ased_rx
CURRENT_DATE=$(date +%Y-%m-%d)
BACKUPS_PATH=/mnt/db_backups_arch/db/day
SHARE=/mnt/db_backups_arch
EXPIRE_DAYS=6

mount $SHARE

echo "     Ежед.    |    Полн.   | $(date "+%d-%m-%Y") $(date "+%H:%M") |   Удаление архивов старше $EXPIRE_DAYS    " >> /srv/journal.txt
find $BACKUPS_PATH -type f -mtime +$EXPIRE_DAYS -delete

if ! mount $SHARE; then
    echo "архивное хранилище успешно примонтировано"
    echo "     Ежед.    |    Полн.   | $(date "+%d-%m-%Y") $(date "+%H:%M") |   Хранилище смонтировано    " >> /srv/journal.txt
else
    echo "не удалось примонтировать архивное хранилище"
    echo "     Ежед.    |    Полн.   | $(date "+%d-%m-%Y") $(date "+%H:%M") |   ОШИБКА монтирования архивного хранилища    " >> /srv/journal.txt
fi

####################################
#Backup PostgreSQL database

echo "     Ежед.    |    Полн.   | $(date "+%d-%m-%Y") $(date "+%H:%M") |   Создаем бэкап базы данных    " >> /srv/journal.txt

su - postgres -c "pg_dump $POSTGRES_DB > $BACKUPS_PATH/$POSTGRES_DB'_'$CURRENT_DATE'.dump'"
tar -cf $BACKUPS_PATH/$POSTGRES_DB'_'$CURRENT_DATE'.tar'  $BACKUPS_PATH/$POSTGRES_DB'_'$CURRENT_DATE'.dump'

if [[ -n $(find "$BACKUPS_PATH" -type f -name "*$CURRENT_DATE'.tar'") ]]; then
    echo "     Ежед.    |    Полн.   | $(date "+%d-%m-%Y") $(date "+%H:%M") |   Бэкап базы данных создан     " >> /srv/journal.txt
    rm $BACKUPS_PATH/$POSTGRES_DB'_'$CURRENT_DATE'.dump'
    echo "     Ежед.    |    Полн.   | $(date "+%d-%m-%Y") $(date "+%H:%M") |   Удаление dump файла выполнено" >> /srv/journal.txt
else
    echo "     Ежед.    |    Полн.   | $(date "+%d-%m-%Y") $(date "+%H:%M") |   Бэкап базы данных не создан  " >> /srv/journal.txt
fi

umount -l $SHARE

if ! umount -l $SHARE; then
    echo "архивное хранилище успешно отмонтировано"
    echo "     Ежед.    |    Полн.   | $(date "+%d-%m-%Y") $(date "+%H:%M") |  архивное хранилище отмонтировано" >> /srv/journal.txt
    echo "     Ежед.    |    Полн.   | $(date "+%d-%m-%Y") $(date "+%H:%M") |  архивное хранилище отмонтировано" >> $LOGS_PATH
else
    echo "не удалось отмонтировать резервное хранилище"
    echo "     Ежед.    |    Полн.   | $(date "+%d-%m-%Y") $(date "+%H:%M") |  ОШИБКА отмонтирования резервного хранилища" >> /srv/journal.txt
    echo "     Ежед.    |    Полн.   | $(date "+%d-%m-%Y") $(date "+%H:%M") |  ОШИБКА отмонтирования резервного хранилища" >> $LOGS_PATH
fi