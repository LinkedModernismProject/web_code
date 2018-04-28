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
echo "Does the Subject already exist in RelFinder? (yes|no)"
read -r exists
echo "If they exist did you want to Delete this Subject? (yes|no)"
read -r perm_del
echo "Please enter the Subject you want inserted/deleted (use _ instead of spaces to separate words):"
read -r ins_del_subj
echo "Please enter the Predicate you want inserted/deleted (use camel case ex: typeOfPerson):"
read -r ins_del_pred
echo "Please enter the Object you want inserted/deleted:"
read -r ins_del_obj
echo "Please enter your SPARQL Password: "
read -sr SPARQL_PASSWORD

ins_del_subj="${ins_del_subj// /_}"
str_subj="${ins_del_subj//_/ }"
ins_del_obj="${ins_del_obj// /_}"

if [ "insert" = "$ins_del" ] ; then
	echo "inserting~~~"
	../../../../../../../bin/isql 1111 $user $SPARQL_PASSWORD <<-EOF
	  sparql PREFIX meta: <http://modernism.uvic.ca/metadata/> PREFIX pref1: <http://localhost:8890/limo/> INSERT DATA INTO <http://localhost:8890/bestDataRelFinder> { meta:$ins_del_subj  pref1:$ins_del_pred  meta:$ins_del_obj } ;
	  EXIT;
	EOF
	echo "Thank you for entering data."
elif [ "delete" = "$ins_del" ] ; then
	echo "deleting~~~"
	../../../../../../../bin/isql 1111 $user $SPARQL_PASSWORD <<-EOF
	  sparql PREFIX meta: <http://modernism.uvic.ca/metadata/> PREFIX pref1: <http://localhost:8890/limo/> DELETE DATA FROM <http://localhost:8890/bestDataRelFinder> { meta:$ins_del_subj  pref1:$ins_del_pred  meta:$ins_del_obj } ;
	  EXIT;
	EOF
	echo "Thank you for cleaning up our data."
else
	echo "Ending appropriately, or you may need to type a valid command: 'insert' or 'delete'"
fi
if [ "no" = "$exists" ] ; then
	echo "creating~~~"
	../../../../../../../bin/isql 1111 $user $SPARQL_PASSWORD <<-EOF
	  sparql PREFIX meta: <http://modernism.uvic.ca/metadata/> PREFIX pref1: <http://localhost:8890/limo/> PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#> INSERT DATA INTO <http://localhost:8890/bestDataRelFinder> { meta:$ins_del_subj  rdfs:label  "$str_subj" } ;
	  EXIT;
	EOF
elif [ "yes" = "$perm_del" ] ; then
	echo "removing~~~"
	../../../../../../../bin/isql 1111 $user $SPARQL_PASSWORD <<-EOF
	  sparql PREFIX meta: <http://modernism.uvic.ca/metadata/> PREFIX pref1: <http://localhost:8890/limo/> PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#> DELETE DATA FROM <http://localhost:8890/bestDataRelFinder> { meta:$ins_del_subj  rdfs:label  "$str_subj" } ;
	  EXIT;
	EOF
else
	echo "Ending appropriately, no creation or removals of Subject entities was asked"
fi
