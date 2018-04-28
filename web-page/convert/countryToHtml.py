import re
import sys
#Pass an input file arg and an output file arg, originally wrote to take predsToAdd.txt
open(sys.argv[2], 'a').close()	#To create output file if hasn't been already
f = open(sys.argv[1], 'r')
fo = open(sys.argv[2], 'r+')

Country = False
html = ''
print 'yes'
for line in f:
  print line
  if Country:
    print 'in the TRUE'
    arr = line.split(',')
    print len(arr)
    fo.write(str(len(arr))+'\n')
    for c in arr:
      co = c.replace('*', '')
      html += '<li><paper-checkbox class="teal" value="'+co+'">'+co+'</paper-checkbox></li>\n'
  if line=='Countries\n':
    print 'inCountryTrue'
    Country=True
print html
fo.write(html)

f.close()
fo.close()