#!/usr/bin/python
# -*- coding: UTF-8 -*-
#Using files truncate.py and fout.txt false_out.txt tout.txt and true_out.txt to figure out all the special characters

#f = open('mytest_additions_ridOfSpecCharsTry.nt', 'r')
f = open('out.nt', 'r')
fp = open('parsed.ttl', 'r+w')
#Next 4 files for tests
ft = open('true_out.txt', 'r+w')
ff = open('false_out.txt', 'r+w')
tout = open('tout.txt', 'r+w')
fout = open('fout.txt', 'r+w')
i=0	#increment var
attr = []
attr2 = []

##HERE converting to Turtle
def processing_for_prefix(pred):
	p_str = pred.split('<http://modernism.uvic.ca/metadata#')
	p_str = ''.join(p_str)
	p_str = p_str.replace('>', '')
	p_str = p_str.replace('(', '')
	p_str = p_str.replace(')', '')
	p_str = p_str.replace('[', '')
	p_str = p_str.replace(']', '')
	p_str = p_str.replace('+', '')
	p_str = p_str.replace("'", '-')
	if '/' in p_str:
		p_str = p_str.rsplit('/', 1)
		return p_str
	else:
		return ['', p_str]

def comb_object(ls):	#Strips the Subj and Predicate and the ending .\n from list and returns the obj combined as a string
	lst = ls[:]
	del lst[0:2]
	del lst[-1]
	ob = ''
	x = 0
	for o in lst:
		if len(lst)==x+1:
			ob += o
		else:
			ob += o + ' '
		x+=1
	return ob

currSubj = ''
p_inc = 0
modernism = '<http://modernism.uvic.ca/metadata#'
pref_num = 'pref'+`p_inc`+':'
pref_zero = 'pref0:'
pre_prefix = '@prefix pref'+`p_inc`+': '
prefixes = [pre_prefix+'<http://modernism.uvic.ca/metadata#> .'] #list for prefixes
turtle = ''

#WORKING ON FIXING () IN PREDICATES NOW #Line 1765 #Good to 2186 # Works now
for line in f:
	#if i>5:
	#	break
	ls = line.split(' ')
	pred = processing_for_prefix(ls[1])
	if pred[0]:	#Testing if their is a string for a prefix to add
		p_inc += 1
		pre_prefix = '@prefix pref'+`p_inc`+': '
		prefixes.append(pre_prefix+modernism+pred[0]+'/> .')
	obj = comb_object(ls)	#Object as a string

	#break
	##print 'ls='+ `ls`
	#print ls[0]	#Type str
	#Use rsplit
	pref_num = 'pref'+`p_inc`+':'
	if ls[0]!=currSubj and not turtle:	#Diff subject & turtle=[]
		#print 'in if'
		currSubj = ls[0]
		if pred[0]:	#Something in prefix
			turtle += ls[0] + '\n\t' + pref_num + pred[1] + ' ' + obj
		else:	#Use empty Prefix
			turtle += ls[0] + '\n\t' + pref_zero +  pred[1] + ' ' + obj
	elif ls[0]!=currSubj:	#Diff subject
		#print 'in elif'
		currSubj = ls[0]
		turtle += ' . \n\n'
		if pred[0]:	#Something in prefix
			turtle += ls[0] + '\n\t' + pref_num + pred[1] + ' ' + obj
		else:	#Use empty Prefix
			turtle += ls[0] + '\n\t' + pref_zero +  pred[1] + ' ' + obj
	else:	#Same subject
		#print 'in else'
		turtle += ' ;\n\t'
		if pred[0]:	#Something in prefix
			turtle += pref_num +  pred[1] + ' ' + obj
		else:	#Use empty Prefix
			turtle += pref_zero +  pred[1] + ' ' + obj

	#break
	i+=1
turtle += ' .'	#For ending period after the file is done
print prefixes
for fixes in prefixes:
	fp.write(fixes+'\n')
fp.write('\n')
fp.write(turtle)
	#attr.append(line.split('<http://modernism.uvic.ca/metadata#'))

	#print `i` #str(line.isalnum())
	#print attr[i]
	#i+=1

#for ite in attr:
 #   fp.write('%s' % ite)
#print attr
print 'OUT'

f.close()
fp.close()

#This doesn't work below
#with open('parsed.txt', 'a+') as fpar:
#	fpar.seek(0,0)
#	fpar.write('\n\n\nHey this is a\nTest of the\nNew Line after open\ntesting a bit moretest\n\n\n')


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

#May not even need what's all below, cause of modifications to the convertCSVtoRDF_dust_test.py file
##for ls in attr:
##	j=0
##	for spo in ls:	#subject predicate object
##		if j=0:
##
##		spo = spo.replace('>', '')
##print attr
#	ab = ("".join(a))
#	ab = ab.replace("Melis", 'Melies')	#Between the i and s there is a special character, looks like a cursor
#	#ab = ab.replace('–', 'n') #Was a special character; had to do manually; Doesn't catch it with replace funct, have to do manually.
#	ab = ab.replace('>', '')
#	ab = ab.replace('"', '')
#	ab = ab.replace('.', '')
#	ab = ab.replace('-', '')
#	ab = ab.replace('(', '')
#	ab = ab.replace(')', '')
#	ab = ab.replace(';', '')
#	#ab = ab.replace('', '') #This character is the result of some special char not working
#	ab = ab.replace('!', '')
#	ab = ab.replace('/', '')
#	ab = ab.replace('\\', '')
#	ab = ab.replace(':', '')
#	ab = ab.replace('&', '')
#	ab = ab.replace(',', '')
#	ab = ab.replace("'", '')
#	ab = ab.replace('>', '')
#	ab = ab.strip('\n')
#	ab = ab.split(' ')
#	attr2.append(''.join(ab))
#
#f.seek(0,0)
##print attr2
#for d in attr2:
#	i+=1
#	if d.isalnum():
#		ft.write(`i` + '\t' + str(d.isalnum()) + '\n')
#		tout.write(`i` + '\t' + f.readline())
#	else:
#		if i==20:
#			print d
#		if i==38:
#			print d
#		ff.write(`i` + '\t' + str(d.isalnum()) + '\n')
#		fout.write(`i` + '\t' + f.readline())
#	#print `i` + '\t' + str(d.isalnum())
#
#
ft.close()
ff.close()
tout.close()
fout.close()