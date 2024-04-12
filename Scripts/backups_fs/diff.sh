#!/bin/bash

current_date=$(date +%Y-%m-%d)
log_file=backup.log
source1=/files/DRX_FS
target1=/mnt/fs_backup/fs/day
target2=/archiv/fs_backups/day
share=/mnt/fs_backup


# Выполняем проверку наличия файла с метаданными
if [ ! -f "/archiv/fs_backups/meta/example.snar" ]; then
    echo "file not in directory"
    exit 1
fi


##Создаём новую запись в журнале##
rm -rf /archiv/fs_backups/day/example2.snar
cp /archiv/fs_backups/meta/example.snar /archiv/fs_backups/day/example2.snar

tar -cf $target2/$current_date'.tar' --listed-incremental=/archiv/fs_backups/day/example2.snar $source1;

if [[ -n $(find "$target2" -type f -name "$current_date*") ]]; then
    echo "     Ежед.    |    Дифф.   | $(ls -t /archiv/fs_backups/section/ | head -1)  | $(date "+%d-%m-%Y") $(date "+%H:%M") |   $current_date'.tar'  | $target2 |  $(du -sh $target2/$current_date* | cut -f 1) " >> /srv/journal.txt
else
    echo "     Ежед.    |    Дифф.   | $(date "+%d-%m-%Y") $(date "+%H:%M") |   Бэкап фх не создан  " >> /srv/journal_log.txt
fi


# Удаляем архив если их число больше или равно 7
if [ $(ls -1q $target2 | wc -l) -gt 7 ]; then
    rm -rf /$target2/$(ls -1t $target2 | tail -1)
fi


mount -t cifs -o user=directum.dc,pass=VEV10warn!proc //10.135.151.153/ASED_RX_Backup $share

if [ $? -eq 0 ]; then
    echo "архивное хранилище успешно примонтировано"
else
    echo "не удалось примонтировать архивное хранилище"
fi


cp $target2/$current_date'.tar' $target1


if [[ -n $(find "$target1" -type f -name "$current_date*") ]]; then
    echo "     Ежед.    |    Дифф.   | $(date "+%d-%m-%Y") $(date "+%H:%M") |   Бэкап перенесен на FS    " >> /srv/journal_log.txt
else
    echo "     Ежед.    |    Дифф.   | $(date "+%d-%m-%Y") $(date "+%H:%M") |   Бэкап не перенесен на FS    " >> /srv/journal_log.txt
fi

echo "     Ежед.    |    Дифф.   | $(date "+%d-%m-%Y") $(date "+%H:%M") |   Удаление архивов старше 6 дней    " >> /mnt/fs_backup/fs/logs/$current_date'_'$log_file
echo "     Ежед.    |    Дифф.   | $(date "+%d-%m-%Y") $(date "+%H:%M") |   Удаление архивов старше 6 дней    " >> /srv/journal_log.txt


# Удаляем архив если их число больше или равно 7
if [ $(ls -1q $target2 | wc -l) -gt 7 ]; then
    rm -rf /$target2/$(ls -1t $target2 | tail -1)
fi


umount -l $share

if [ $? -eq 0 ]; then
    echo "архивное хранилище успешно отмонтировано"
    echo "     Ежед.    |    Дифф.   | $(date "+%d-%m-%Y") $(date "+%H:%M") |  архивное хранилище отмонтировано" >> /srv/journal_log.txt
else
    echo "не удалось отмонтировать резервное хранилище"
    echo "     Ежед.    |    Дифф.   | $(date "+%d-%m-%Y") $(date "+%H:%M") |  ОШИБКА отмонтирования резервного хранилища" >> /srv/journal_log.txt
fi

