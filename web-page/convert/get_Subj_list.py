import re
import sys
#Pass an input file arg and an output file arg, originally wrote to take bestDataTest.ttl
open(sys.argv[2], 'a').close()	#To create output file if hasn't been already
f = open(sys.argv[1], 'r')
fo = open(sys.argv[2], 'r+')

#Subjs on line 20608 in auto.js at this time
ent_count = 0	#To double check produced correct amount of triples
for line in f:
	if(re.match('^<http://modernism.uvic.ca/metadata#(.*)>', line) is not None):	#re.search('^\s$', line) only for grabbing separator lines
		subjs = re.match('^<http://modernism.uvic.ca/metadata#(.*)>', line)
		fo.write('"'+subjs.group(1).replace("_", ' ')+'",\n')

print ent_count
f.close()
fo.close()