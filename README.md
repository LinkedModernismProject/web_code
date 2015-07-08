#web_code resources
Miscellaneous:
* flourishesIn should be continuous in dataset (Priority: Low)
* hasBirthdate/Deathdate, possibly have the dates in another pred?
* Combine all the isPerson, isEvent, isArtifact... to hasType

postgres info (starts it): postgres -D /Users/brayden/limo/iepy/limo/db/

**scp info:**

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;scp to WestCloud: scp -C -i ~/.ssh/key.pem  filename centos@IP:/path/to/destination

launch chromium: /opt/chromium/chrome-wrapper %U

**localhost:** localhost:8890

/usr/local/virtuoso-opensource/var/lib/virtuoso/vsp/

Possibly?
/usr/local/virtuoso-opensource/var/lib/virtuoso/vsp/bin

Search recursively through files for a string:

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;grep -rli 'string' .

Search recursively through dir's for file names:

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;find . -name 'filename*'

Search recursively through dir's for directory names:

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;find . -type d -name 'filename*'

Grep history:

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;history | grep cmd_name

Uploading tasks:
* Possibe changes to quotes to JSON file make by d3.xhr, may need to modify convertJSONtoFlare.js

___________________________________________________________________________________________________

~/www/rdfconvert/rdfconvert-0.4/bin/
	Searched for all www directories from root and only found this few:
	./usr/share/cups/www
	./usr/lib64/R/library/shiny/examples/08_html/www
	./usr/lib64/R/library/shiny/www
	./home/cloud-user/anaconda/lib/python2.7/site-packages/www
	./var/shiny-server/www
	./var/shiny-server/www/examples/08_html/www

1data/allRespones/CSV

/usr/local/virtuoso-opensource/var/lib/virtuoso/vsp/vis/rdfbrowser2/js/main.js

/usr/local/virtuoso-opensource/var/lib/virtuoso/vsp/index.html

/usr/local/virtuoso-opensource/var/lib/virtuoso/vsp/vis/oat/datasource.js

~/data/ntriples.n3
~/data/onePage.nt

~/opendata2/onePage.csv

Setting up rsub:
	http://log.liminastudio.com/writing/tutorials/sublime-tunnel-of-love-how-to-edit-remote-files-with-sublime-text-via-an-ssh-tunnel
	For Host part:
		Host IP
		    RemoteForward 52698 127.0.0.1:52698

RDFConvert:
	First convert to JSON:
		/home/cloud-user/opendata2/convertCSVtoRDF.py
	Convert from JSON to N3:
		/usr/local/virtuoso-opensource/var/lib/virtuoso/vsp/rdfconvert/rdfconvert-0.4/bin/rdfconvert.sh
	How to run:
		rdfconvert.sh -i N-Triples -o N3 mytest.nt output.n3


It is recommended that Turtle files have the extension ".ttl" (all lowercase) on all platforms.


~/data/onePage.nt
~/data/ntriples.n3


Working On:
	You have attempted to upload invalid data. You can only upload RDF, Turtle, N3 serializations of RDF Data to the RDF Data Store.


Special character regex:
	[^\x00-\x7F]

To query the data base go into tabs: 'Linked Data'->SPARQL
	Type the graph IRI
	select * where {?s ?p ?o}


Turtle
	Subject
		No spaces allowed
		Some special char's allowed
			Not Allowed: < >
	Predicate
		No spaces allowed
		Some special char's allowed
			Not Allowed: < >
		Not allowed / char in string
		Now allowed () in string
		Now allowed [] in string
		Now allowed + in string
	Object
		Spaces allowed
		Special characters allowed, even < >
		Allowed () char's


	Sample Turtle
		@prefix ns0: <http://modernism.uvic.ca/metadata#> .
		<http://modernism.uvic.ca/metadata#Jean_Rhys>
			ns0:prose "hhkjh Å½liÂ<8f>s" ;
			ns0:Response "Yes" ;
			ns0:novelist "True" ;
			ns0:story_writer "True" ;
			ns0:performer "True" .

startVirtuoso.sh
	cd /usr/local/virtuoso-opensource/bin/
	sudo ./virtuoso-t -f &

Querying Dataset:
	select ?obj where {<http://modernism.uvic.ca/metadata#Lajos_Kassk,_The_Ma_Group> <http://modernism.uvic.ca/metadata#Open-Ended_Response> ?obj .}
	select ?p ?o where {<http://modernism.uvic.ca/metadata#Lajos_Kassk,_The_Ma_Group> ?p ?o .}
