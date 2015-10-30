import re
import sys
#Pass an input file arg and an output file arg, originally wrote to take bestDataE.ttl
open(sys.argv[2], 'a').close()	#To create output file if hasn't been already
f = open(sys.argv[1], 'r')
fo = open(sys.argv[2], 'r+')

ent_count = 0	#To double check produced correct amount of triples
for line in f:
	if(re.match('^<http://modernism.uvic.ca/metadata#(.*)>', line) is not None):	#re.search('^\s$', line) only for grabbing separator lines
		fo.write(line)
		ent_count += 1
	elif re.match('([\s]+)*([^:]+):([^\s]+).*:([^\s]+)\s*(;|.)', line) is not None:	#Match against any that isn't a subject or label
		matches = re.match('([\s]+)*([^:]+):([^\s]+).*:([^\s]+)\s*(;|.)', line)
		fo.write(matches.group(1) + matches.group(2) + ':' + matches.group(3) + ' "' + matches.group(4).replace('_', ' ') + '" ' + matches.group(5) + '\n')
	else:
		fo.write(line)

print ent_count
f.close()
fo.close()