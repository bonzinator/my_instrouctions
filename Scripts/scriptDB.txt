#!/bin/bash

db_name=ased_rx
db_user=postgres
#db_pass=1Qaz!2Wsx@
db_host="10.135.151.95"
db_port="5432"
share=/db_backup
backupfolder=/db_backup/week
#recipient_email=youremail@example.ru
# Сколько дней хранить файлы
keep_day=7
sqlfile=$backupfolder/$(date +%d-%m-%Y).sql
#tarfile=$backupfolder/database-$(date +%d-%m-%Y).tar

umount -l $share
echo "монтирование архивного хранилища.."
if ! [-d $backupfolder]; then
  mount $share
  if [ $? -eq 0 ]; then
    echo "архивное хранилище успешно примонтировано"
    echo "    Еженед.   |    Полн.   | $(date "+%d-%m-%Y") $(date "+%H:%M") |   Хранилище смонтировано    " >> /srv/journal.txt
  else
    echo "не удалось примонтировать архивное хранилище"
    echo "    Еженед.   |    Полн.   | $(date "+%d-%m-%Y") $(date "+%H:%M") |   ОШИБКА монтирования архивного хранилища  " >> /srv$
    exit 1
  fi
else echo "архивное хранилище уже смонтировано"
fi
if pg_dump --file $sqlfile --host $db_host --port $db_port --username $db_user --no-password --verbose $db_name ; then
   echo "Резервная копия успешно создана"
   echo "    Еженед.   |    Полн.   | $(date "+%d-%m-%Y") $(date "+%H:%M") |  $sqlfile |   $(du -hs $sqlfile | cut -f 1)    " >> /$
else
   echo "Ошибка создания резервной копии"
   echo "    Еженед.   |    Полн.   | $(date "+%d-%m-%Y") $(date "+%H:%M") |   ОШИБКА создания резервной копии   " >> /srv/journal$
   exit
fi
echo "удаление устаревших файлов резервных копий.. "
find $backupfolder -type f -mtime +$keep_day -delete
echo "отмонтирование архивного хранилища.."
umount $share
if [ $? -eq 0 ]; then
   echo "архивное хранилище успешно отмонтировано"
   echo "    Еженед.   |    Полн.   | $(date "+%d-%m-%Y") $(date "+%H:%M") |  архивное хранилище отмонтировано" >> /srv/journal.txt
else
   echo "не удалось отмонтировать резервное хранилище"
   echo "    Еженед.   |    Полн.   | $(date "+%d-%m-%Y") $(date "+%H:%M") |  ОШИБКА отмонтирования резервного хранилища" >> /srv/$
fi
#if tar -cf $tarfile $sqlfile; then
#   echo 'The backup was successfully compressed'
#   rm -rf $sqlfile
#else
#   echo 'Error compressing backup'
#   exit
#fi
#echo $tarfile | mailx -s -a $sqlfile 'Backup was successfully created'
