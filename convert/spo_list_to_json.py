import re
import sys
#Pass an input file arg and an output file arg, originally wrote to take subject_list_ordered.txt
open(sys.argv[2], 'a').close()	#To create output file if hasn't been already
f = open(sys.argv[1], 'r')
fo = open(sys.argv[2], 'r+')


fo.write('{\n')   #Start of json file
line_num = 0
for line in f:
    l_match = re.match('(.*)\n', line)
    if(line_num == 0):
        fo.write('"' + str(line_num) + '" : "' + l_match.group(1) + '"')
    else:
        fo.write(',\n"' + str(line_num) + '" : "' + l_match.group(1) + '"')
    line_num += 1


fo.write('\n}')   #End of json file
f.close()
fo.close()