import os
from unidecode import unidecode

entity_file = open("/Users/brayden/Downloads/sendBackToBraydenWhenDone.txt", 'r')
ttlFile = open("/Users/brayden/Downloads/newdata.ttl",'w')

with open("/Users/brayden/Downloads/sendBackToBraydenWhenDone.txt", 'r') as entity_file:
    file_lines = entity_file.readlines()
    for i in range(0,len(file_lines)):
        file_split = file_lines[i].split('\t\t')
        ttlFile.write("<http://modernism.uvic.ca/metadata#" + unidecode(file_split[0].replace(' ','_')) + ">\n")
        ttlFile.write("\tpref1:" + file_split[2].replace('\n','') + ' "' + file_split[1] + '" .\n\n')
