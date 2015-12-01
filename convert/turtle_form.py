import re
import sys
#Pass an input file arg and an output file arg, originally wrote to take out_triples.txt
open(sys.argv[2], 'a').close()	#To create output file if hasn't been already
f = open(sys.argv[1], 'r')
fo = open(sys.argv[2], 'r+')

fo.write('@prefix pref0: <http://modernism.uvic.ca/metadata#> . \n@prefix pref1: <http://localhost:8890/limo#> . \n@prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> . \n\n')

for line in f:
    if re.match('entity_name:\s+(.+)', line) is not None:
        ent_match = re.match('entity_name:\s+(.+)', line)
        fo.write('<http://modernism.uvic.ca/metadata#' + ent_match.group(1).replace(' ', '_') + '>\n')
    elif re.match('(alt_entity_names|birth_date|death_date|selSexuality|selGender|selSex|ethnic|plang|createdBy|place):\s+(.+)', line) is not None:
        names = re.match('(alt_entity_names|birth_date|death_date|selSexuality|selGender|selSex|ethnic|plang|createdBy|place):\s+(.+)', line)
        if names.group(1) == alt_entity_names:
            alt_names = names.group(1).split(',')
            fo.write('\tpref1:hasAlias "' + alt_names[0] + '" ;')
            if len(alt_names) > 1:
                for a in alt_names[1:]:
                    pass

        elif names.group(1 == birth_date):
            pass
        elif names.group(1 == death_date):
            pass
        elif names.group(1 == selSexuality):
            pass
        elif names.group(1 == selGender):
            pass
        elif names.group(1 == selSex):
            pass
        elif names.group(1 == ethnic):
            pass
        elif names.group(1 == plang):
            pass
        elif names.group(1 == createdBy):
            pass
        elif names.group(1 == place):
            pass



    elif None:
        pass














f.close()
fo.close()
