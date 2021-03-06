#!/bin/bash
user="vspdemo"
echo "Would you like to INSERT data or DELETE data?"
read -r ins_del
ins_del="${ins_del,,}"
if [[ "insert" != "$ins_del" && "delete" != "$ins_del" ]] ; then
	echo "Ending appropriately, or you may need to type a valid command: 'insert' or 'delete'"
	exit 0
fi
echo "Please enter the following information (Case Sensitive):"
echo "Please enter the Subject you want inserted/deleted (use _ instead of spaces to separate words):"
read -r ins_del_subj
echo "Please enter the Predicate you want inserted/deleted (use camel case ex: typeOfPerson):"
read -r ins_del_pred
echo "Please enter the Object you want inserted/deleted:"
read -r ins_del_obj
echo "Please enter your SPARQL Password: "
read -sr SPARQL_PASSWORD

if [ "insert" = "$ins_del" ] ; then
	echo "inserting~~~"
	./isql 1111 $user $SPARQL_PASSWORD <<-EOF
	  sparql PREFIX meta: <http://modernism.uvic.ca/metadata#> PREFIX pref1: <http://localhost:8890/limo#> INSERT DATA INTO <http://localhost:8890/dustin> { meta:$ins_del_subj  pref1:$ins_del_pred  "$ins_del_obj" } ;
	  EXIT;
	EOF
	echo "Thank you for entering data."
elif [ "delete" = "$ins_del" ] ; then
	echo "deleting~~~"
	./isql 1111 $user $SPARQL_PASSWORD <<-EOF
	  sparql PREFIX meta: <http://modernism.uvic.ca/metadata#> PREFIX pref1: <http://localhost:8890/limo#> DELETE DATA FROM <http://localhost:8890/dustin> { meta:$ins_del_subj  pref1:$ins_del_pred  "$ins_del_obj" } ;
	  EXIT;
	EOF
	echo "Thank you for cleaning up our data."
else
	echo "Ending appropriately, or you may need to type a valid command: 'insert' or 'delete'"
fi
