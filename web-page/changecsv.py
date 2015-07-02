import os

infile = open('20150309Workbookv3_ontology2.csv', 'r', encoding='utf-8')
firstLine = infile.readline()
firstLine.split(',')
tmp = ""
for x in firstLine:
    if(x != '\"\"'):
        tmp = x
    elif(x == '\"\"'):
        x = tmp
firstLine = ','.join(firstLine)
outfile = open('outcsv.csv','w')
outfile.write(firstLine)
outfile.write(infile)
