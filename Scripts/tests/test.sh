#!/bin/bash

I=$1

result=$(( $I >= 100 && $I <= 200 ))

if [ $result -eq 1 ]; then
	echo "$I is between 100 and 200"
    echo "$result"
else
	echo "$I is not between 100 and 200"
    echo "$result"
fi


