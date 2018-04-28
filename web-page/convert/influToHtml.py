import re
import sys
#Pass an input file arg and an output file arg, originally wrote to take predsToAdd.txt
open(sys.argv[2], 'a').close()	#To create output file if hasn't been already
f = open(sys.argv[1], 'r')
fo = open(sys.argv[2], 'r+')

lang = False
html = ''
for line in f:
  if lang:
  	s = line.replace('"', '').replace(',', '').strip()
  	html += '<paper-item class="ctTeal" value="'+s+'">'+s+'</paper-item>\n'
  if line=='Subjects\n':
    print 'inLangTrue'
    lang=True
print html
fo.write(html)

f.close()
fo.close()