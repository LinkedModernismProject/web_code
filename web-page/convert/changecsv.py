import os

infile = open('20150309Workbookv3_ontology3.txt', 'r', encoding='ISO-8859-1')
firstLine = infile.readline()
firstLine2 = firstLine.split(',')
tmp = ""
fulls = ""
for x in firstLine2:
    print(tmp)
    if(x != ''):
        tmp = x
        fulls += tmp + ','
    elif(x == ''):
        fulls += tmp + ','
outfile = open('outcsv.csv','w')
outfile.write(fulls)
