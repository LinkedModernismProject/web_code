#!/usr/bin/python
#Using files truncate.py and fout.txt false_out.txt tout.txt and true_out.txt to figure out all the special characters

f = open('mytest_additions_ridOfSpecCharsTry.nt', 'r')
#f = open('test.txt', 'r')
ft = open('true_out.txt', 'r+w')
ff = open('false_out.txt', 'r+w')
tout = open('tout.txt', 'r+w')
fout = open('fout.txt', 'r+w')
i=0
attr = []
attr2 = []
for line in f:
	attr.append(line.split('<http://modernism.uvic.ca/metadata#'))

	#print `i` #str(line.isalnum())
	#i+=1
for a in attr:
	ab = ("".join(a))
	ab = ab.replace('>', '')
	ab = ab.replace('"', '')
	ab = ab.replace('.', '')
	ab = ab.replace('-', '')
	ab = ab.replace('(', '')
	ab = ab.replace(')', '')
	ab = ab.replace(';', '')
	#ab = ab.replace('–', '') #This character is the result of some special char not working
	ab = ab.replace('!', '')
	ab = ab.replace('/', '')
	ab = ab.replace('\\', '')
	ab = ab.replace(':', '')
	ab = ab.replace('&', '')
	ab = ab.replace(',', '')
	ab = ab.replace("'", '')
	ab = ab.replace('>', '')
	ab = ab.strip('\n')
	ab = ab.split(' ')
	attr2.append(''.join(ab))

f.seek(0,0)
#print attr2
for d in attr2:
	i+=1
	if d.isalnum():
		ft.write(`i` + '\t' + str(d.isalnum()) + '\n')
		tout.write(`i` + '\t' + f.readline())
	else:
		if i==20:
			print d
		if i==38:
			print d
		ff.write(`i` + '\t' + str(d.isalnum()) + '\n')
		fout.write(`i` + '\t' + f.readline())
	#print `i` + '\t' + str(d.isalnum())


ft.close()
ff.close()
f.close()