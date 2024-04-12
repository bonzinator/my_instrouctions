#! /bin/bash

while [ ! -f "./meta.txt" ]; do
    echo "file not in directory"
    sleep 5
done


echo "Success"
