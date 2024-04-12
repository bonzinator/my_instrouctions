#!/bin/bash

current_date=$(date +%Y-%m-%d)
source1=/files/DRX_FS
target1=/mnt/fs_backup/fs/section
target2=/archiv/fs_backups/section
share=/mnt/fs_backup




rm -rf /archiv/fs_backups/meta/main/example.snar
rm -rf /archiv/fs_backups/meta/example.snar

tar -cf $target2/$current_date'.tar' --listed-incremental=/archiv/fs_backups/meta/main/example.snar $source1;

if [[ -n $(find "$target2" -type f -name "$current_date*") ]]; then
    echo "     Кварт.    |    Полн.   |  $(date "+%d-%m-%Y") $(date "+%H:%M") |   $current_date'.tar'  | $target2 |  $(du -sh $target2/$current_date* | cut -f 1) " >> /srv/journal.txt
else
    echo "     Кварт.    |    Полн.   | $(date "+%d-%m-%Y") $(date "+%H:%M") |   Бэкап фх не создан  " >> /srv/journal_log.txt
fi

cp /archiv/fs_backups/meta/main/example.snar /archiv/fs_backups/meta/example.snar

# Удаляем архив если их число больше или равно 4
if [ $(ls -1q $target2 | wc -l) -gt 4 ]; then
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
    echo "     Кварт.    |    Полн.   | $(date "+%d-%m-%Y") $(date "+%H:%M") |   Бэкап перенесен на FS    " >> /srv/journal_log.txt
else
    echo "     Кварт.    |    Полн.   | $(date "+%d-%m-%Y") $(date "+%H:%M") |   Бэкап не перенесен на FS    " >> /srv/journal_log.txt
fi

#find $target1 -type f -mtime +365 -delete

if [ $(ls -1q $target1 | wc -l) -gt 4 ]; then
    rm -rf /$target1/$(ls -1t $target1 | tail -1)
fi

umount -l $share

if [ $? -eq 0 ]; then
    echo "архивное хранилище успешно отмонтировано"
else
    echo "не удалось отмонтировать резервное хранилище"
fi

