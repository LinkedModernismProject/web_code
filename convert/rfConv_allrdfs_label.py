import re
import sys
#Pass an input file arg and an output file arg, originally wrote to take bestDataE.ttl
open(sys.argv[2], 'a').close()	#To create output file if hasn't been already
f = open(sys.argv[1], 'r')
fo = open(sys.argv[2], 'r+')

for line in f:
	if(re.search('^<http://modernism.uvic.ca/metadata#(.*)>', line) is not None):	#re.search('^\s$', line) only for grabbing separator lines
		fo.write(line)
		fo.write('    rdfs:label "' + re.match('^<http://modernism.uvic.ca/metadata#(.*)>', line).group(1).replace('_', ' ') + '" ;\n')
	elif re.search('^\s*rdf', line) or re.search('^\s*pref', line) is not None:
		mObj = re.match('(\s*)(.*):(.*)\s(.*):(.*)\s(.)', line)
		mObjStr = re.match('(\s*)(.*):(.*)(\s".*"\s)(.)', line)
		if mObj:
			m5_objVal = mObj.group(5).replace('_', ' ')
			modline = mObj.group(1) + 'rdfs:' + mObj.group(3) + ' "' + m5_objVal + '" ' + mObj.group(6) + '\n'
			fo.write(modline)
		elif mObjStr:
			m4_objVal = mObjStr.group(4).replace('_', ' ')
			modlineStr = mObjStr.group(1) + 'rdfs:' + mObjStr.group(3) + m4_objVal + mObjStr.group(5) + '\n'
			fo.write(modlineStr)
	elif re.search('^\s$', line) is not None:
		fo.write(line)

f.close()
fo.close()