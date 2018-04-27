#Ex to run: python turtle_form.py input_data_file output_data_file
import re
import sys
#Pass an input file arg and an output file arg, originally wrote to take out_triples.txt
#Ex to run: python turtle_singles.py test_ts.txt out_turt_sing.txt
open(sys.argv[2], 'a').close()  #To create output file if hasn't been already
f = open(sys.argv[1], 'r')
fo = open(sys.argv[2], 'a')

pred_holder = ''

for line in f:
    if re.match('Subject:\s+(.+)', line) is not None:
        fo.write(re.match('Subject:\s+(.+)', line).group(1) + '\t\t')
    elif re.match('(\s+)(Predicate|Object):\s+(.+)', line) is not None:
        po_match = re.match('(\s+)(Predicate|Object):\s+(.+)', line)
        po_list = po_match.group(3).split(' ')
        po_camel = po_list[0]
        if po_match.group(2) == 'Predicate':
            if len(po_list) > 1:
                for s in po_list[1:]:
                    po_camel += s.capitalize()

        if po_match.group(2) == 'Predicate':
            pred_holder = po_camel + '\n'
        elif po_match.group(2) == 'Object':
            fo.write(' '.join(po_list) + '\t\t' + pred_holder)
    else:
        pass #Shouldn't get here in any case, except the end of the file

f.close()
fo.close()
