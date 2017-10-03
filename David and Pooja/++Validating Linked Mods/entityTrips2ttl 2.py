import os
from unidecode import unidecode

entity_file = open("/Users/stephenross/Desktop/finalResult3.txt", 'r')
ttlFile = open("/Users/stephenross/Desktop/fdata.ttl",'w')

with open("/Users/stephenross/Desktop/finalResult3.txt", 'r') as entity_file:
    file_lines = entity_file.readlines()
    for i in range(0,len(file_lines)):
        file_split = file_lines[i].split()
        print(unidecode(unicode(file_split[0].replace('/','_'),'utf-8')))
        print("\n")
        
        ttlFile.write("<http://modernism.uvic.ca/metadata#" + unidecode(unicode(file_split[0],'utf-8').replace('/\/i0','')).replace('/','_') + ">\n")
        ttlFile.write("\tpref1:" + file_split[2].replace('\n','') + ' "' + file_split[1].replace('/',' ').replace('\ i0','') + '" .\n\n')
