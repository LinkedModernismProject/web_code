#!/usr/bin/python
# -*- coding: UTF-8 -*-
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

#For special characters use regex [^\x00-\x7F]
#Ctrl+Command+G to select all highlighted in sublime

#On line 1088 between M and m in Lui-Mme is the special char
#line 1771 between n and o in Franois
#line 1782 between n then a in Franaise
#line 1791 between i and r in Cimetires
#line 1792 between r and s in Therse and n and o in Franois
#line 2437 between n and g in ngres
#line 3271 between F and t in Fte
#line 4651 between t and r in Mystres
#first 12 are cursor lines
#line 6506 between h and q in Bibliothque


for a in attr:
	ab = ("".join(a))
	ab = ab.replace("Melis", 'Melies')	#Between the i and s there is a special character, looks like a cursor
	#ab = ab.replace('–', 'n') #Was a special character; had to do manually; Doesn't catch it with replace funct, have to do manually.
	ab = ab.replace('>', '')
	ab = ab.replace('"', '')
	ab = ab.replace('.', '')
	ab = ab.replace('-', '')
	ab = ab.replace('(', '')
	ab = ab.replace(')', '')
	ab = ab.replace(';', '')
	#ab = ab.replace('', '') #This character is the result of some special char not working
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