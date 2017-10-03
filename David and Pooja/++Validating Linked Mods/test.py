import os
import sys
reload(sys)
sys.setdefaultencoding("utf-8")
from unidecode import unidecode

entity_file = open("/Users/stephenross/Downloads/finalResult.txt", 'r')
ttlFile = open("/Users/stephenross/Downloads/fdata.ttl",'w')

with open("/Users/stephenross/Downloads/finalResult.txt", 'r') as entity_file:
    file_lines = entity_file.readlines()
    for i in range(0,len(file_lines)):
        file_split = file_lines[i].split()
        ttlFile.write("<http://modernism.uvic.ca/metadata#" + unidecode(file_split[0].replace(' ','_')) + ">\n")
        ttlFile.write("\tpref1:" + file_split[2].replace('\n','') + ' "' + file_split[1] + '" .\n\n')
