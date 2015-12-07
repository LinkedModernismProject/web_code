#!/bin/bash
user="vspdemo"
file="$1"
file2="$2"
echo "Hello, $file, $file2"
echo "Please enter your SPARQL Password: "
read -sr SPARQL_PASSWORD

#Read from file and delimit on tabs (any number of them) and read through array
while IFS=$'\t' read -r -a arr; do
	if [ ! -z "${arr[0]}" ] && [ ! -z "${arr[1]}" ] && [ ! -z "${arr[2]}" ] ; then #To stop from grabbing blank lines in arg file given
		./isql 1111 $user $SPARQL_PASSWORD <<-EOF
		  sparql PREFIX meta: <http://modernism.uvic.ca/metadata#> PREFIX pref1: <http://localhost:8890/limo#> INSERT DATA INTO <http://localhost:8890/dustin> { meta:${arr[0]}  pref1:${arr[2]}  "${arr[1]}" } ;
		  EXIT;
		EOF
	fi
done < "$1"
echo -e "\nThank you for entering data."
