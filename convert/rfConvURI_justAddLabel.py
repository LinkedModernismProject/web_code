import re
import sys
#Pass an input file arg and an output file arg, originally wrote to take bestDataE.ttl
open(sys.argv[2], 'a').close()	#To create output file if hasn't been already
f = open(sys.argv[1], 'r')
fo = open(sys.argv[2], 'r+')

ent_count = 0
for line in f:
	if(re.match('^<http://modernism.uvic.ca/metadata#(.*)>', line) is not None):	#re.search('^\s$', line) only for grabbing separator lines
		fo.write(line)
		fo.write('    rdfs:label "' + re.match('^<http://modernism.uvic.ca/metadata#(.*)>', line).group(1).replace('_', ' ') + '" ;\n')
		ent_count += 1
	elif re.search('^\s*rdf', line) or re.search('^\s*pref', line) is not None:
		fo.write(line)
	elif re.search('^\s$', line) is not None:
		fo.write(line)

print ent_count
f.close()
fo.close()