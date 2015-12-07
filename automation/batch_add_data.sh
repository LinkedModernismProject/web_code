#!/bin/bash
user="vspdemo"
file="$1"
file2="$2"
echo "Hello, $file, $file2"

while IFS=$'\t' read -r -a arr; do
    echo "Text read from file: $line"
    echo "${arr[0]}"
    echo "${arr[1]}"
    echo "${arr[2]}"
    #echo $line | cut -d $'\t' -f2
done < "$1"
