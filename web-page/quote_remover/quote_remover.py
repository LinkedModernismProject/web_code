#!/usr/bin/python
#Produces a second_data.txt file to comepare against first_data.txt that I created just for checking the attributes, just have to remove the few commas at the end of second_data.txt


f = open("attr.txt", "r")
myfi = open("second_data.txt", "r+w")
i = 0 #incrementer
for line in f:	#Will only execute once since one line
	data = line.split('\"')
print '\n\n\n'
#print data
final_data = []
for item in data:
	if item != ',':
		final_data.append(item)

print type (final_data)
for it in final_data:
	it += ','
	myfi.write(it)