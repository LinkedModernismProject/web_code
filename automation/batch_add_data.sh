#!/bin/bash
user="vspdemo"
file="$1"
file2="$2"
echo "Hello, $file, file2"

while IFS='' read -r line || [[ -n "$line" ]]; do
    echo "Text read from file: $line"
done < "$1"
