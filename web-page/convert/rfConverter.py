import re
import sys
f = open('bestDataE.ttl', 'r')
fo = open('bestDataR.ttl', 'r+')

for line in f:
	if(re.search('^<http', line) or re.search('^\s$', line) is not None):	#re.search('^\s$', line) only for grabbing separator lines
		fo.write(line)
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

f.close()
fo.close()