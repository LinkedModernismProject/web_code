import re
import sys
#Pass an input file arg and an output file arg, originally wrote to take predsToAdd.txt
open(sys.argv[2], 'a').close()	#To create output file if hasn't been already
f = open(sys.argv[1], 'r')
fo = open(sys.argv[2], 'r+')

eth = False
html = ''
for line in f:
  if eth:
    arr = line.split(',')
    print len(arr)
    fo.write(str(len(arr))+'\n')
    for e in arr:
      html += '<li><paper-checkbox class="teal" value="'+e+'">'+e+'</paper-checkbox></li>\n'
  if line=='Ethnicity\n':
    print 'inEthTrue'
    eth=True
print html
fo.write(html)

f.close()
fo.close()