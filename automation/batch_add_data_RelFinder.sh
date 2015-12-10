#!/bin/bash
user="vspdemo"
echo "Please enter your SPARQL Password: "
read -sr SPARQL_PASSWORD

#Goes through all .txt files in current dir and adds all triples within them
#txt files need to end in an empty line
for file in *.txt; do
	echo -e "\n|||---Processing $file---|||"
  	##Read from file and delimit on tabs (any number of them) and read through array
  	while IFS=$'\t' read -r -a arr; do
	  	if [ ! -z "${arr[0]}" ] && [ ! -z "${arr[1]}" ] && [ ! -z "${arr[2]}" ] ; then #To stop from grabbing blank lines in arg file given
	  		one_word_obj="${arr[1]// /_}"
	  		str_subj="${arr[0]//_/ }"
	  		echo $one_word_obj
	  		echo $str_subj
		     ../../../../../../../bin/isql 1111 $user $SPARQL_PASSWORD <<-EOF
		       sparql PREFIX meta: <http://modernism.uvic.ca/metadata/> PREFIX pref1: <http://localhost:8890/limo/> INSERT DATA INTO <http://localhost:8890/dustin> { meta:${arr[0]}  pref1:${arr[2]}  meta:$one_word_obj } ;
		       sparql PREFIX meta: <http://modernism.uvic.ca/metadata/> PREFIX pref1: <http://localhost:8890/limo/> PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#> INSERT DATA INTO <http://localhost:8890/dustin> { meta:${arr[0]}  rdfs:${arr[2]} "$str_subj" } ;
				EXIT;
			EOF
      fi
	done < "$file"
done
echo -e "\nThank you for entering data."
