#!/bin/bash

if [ $(ls -1q $target2 | wc -l) -gt 4 ]; then

    # Удаляем самый старый архив
    rm -rf /$target2/$(ls -1t $target2 | tail -1)

else

    echo "Nothing"

fi


if [ $(ls -1q $target1 | wc -l) -gt 3 ]; then

    # Удаляем самый старый архив
    rm -rf /$target1/$(ls -1t $target1 | tail -1)

else

    echo "Nothing"

fi
