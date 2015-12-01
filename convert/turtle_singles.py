import re
import sys
#Pass an input file arg and an output file arg, originally wrote to take out_triples.txt
open(sys.argv[2], 'a').close()	#To create output file if hasn't been already
f = open(sys.argv[1], 'r')
fo = open(sys.argv[2], 'r+')

fo.write('@prefix pref0: <http://modernism.uvic.ca/metadata#> . \n@prefix pref1: <http://localhost:8890/limo#> . \n@prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> . \n\n')

for line in f:
    if re.match('Subject:\s+(.+)', line) is not None:
        subj_match = re.match('Subject:\s+(.+)', line)
        fo.write('<http://modernism.uvic.ca/metadata#'+ subj_match.group(1).replace(' ', '_') + '>\n')
    elif re.match('(\s+)Predicate:\s+(.+)', line) is not None:
        pred_match = re.match('(\s+)Predicate:\s+(.+)', line)
        pred_list = pred_match.split(' ')
        pred_camel = pred_list[0]
        if len(pred_list) > 1:
            for s in pred_list[1:]:
                pass

        fo.write(pred_match.group(1) + 'pref1:' + pred_match.group(3).replace(' ', '') + '\n')
    else:
        pass #Shouldn't get here in any case, except the end of the file

f.close()
fo.close()
