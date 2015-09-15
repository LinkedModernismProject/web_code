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
			#print mObj.group()
			#print mObj.group(1) + '|||' + mObj.group(2) + '|||' + mObj.group(3) + '|||' + mObj.group(4) + '|||' + mObj.group(5) + '|||' + mObj.group(6)
			m5_objVal = mObj.group(5).replace('_', ' ')
			modline = mObj.group(1) + 'rdfs:' + mObj.group(3) + ' "' + m5_objVal + '" ' + mObj.group(6) + '\n'
			#print modline
			fo.write(modline)
		elif mObjStr:
			#print 'STR!:' + mObjStr.group(1) + '|||' + mObjStr.group(2) + '|||' + mObjStr.group(3) + '|||' + mObjStr.group(4) + '|||' + mObjStr.group(5)
			m4_objVal = mObjStr.group(4).replace('_', ' ')
			modlineStr = mObjStr.group(1) + 'rdfs:' + mObjStr.group(3) + m4_objVal + mObjStr.group(5) + '\n'
			#print modlineStr
			fo.write(modlineStr)

f.close()
fo.close()