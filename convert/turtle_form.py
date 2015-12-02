#Ex to run: python turtle_form.py input_data_file output_data_file
import re
import sys
#Pass an input file arg and an output file arg, originally wrote to take out_triples.txt
open(sys.argv[2], 'a').close()	#To create output file if hasn't been already
f = open(sys.argv[1], 'r')
fo = open(sys.argv[2], 'r+')

ent = ''

for line in f:
    if re.match('entity_name:\s+(.+)', line) is not None:
        ent_match = re.match('entity_name:\s+(.+)', line)
        ent = ent_match.group(1)
    elif re.match('(alt_entity_names|birth_date|death_date|occupation_|selSexuality|selGender|selSex|ethnic|pLang|lang_|hasInflu_|wasInflu_|createdBy|place|relatedPlace_).*:\s+(.+)', line) is not None:
        names = re.match('(alt_entity_names|birth_date|death_date|occupation_|selSexuality|selGender|selSex|ethnic|pLang|lang_|hasInflu_|wasInflu_|createdBy|place|relatedPlace_).*:\s+(.+)', line)
        if names.group(1) == 'alt_entity_names':
            fo.write('{}\t\t{}\t\thasAlias\n'.format(ent, names.group(2)))
        elif names.group(1) == 'birth_date':
            fo.write('{}\t\t{}\t\thasBirthdate\n'.format(ent, names.group(2)))
        elif names.group(1) == 'death_date':
            fo.write('{}\t\t{}\t\tterminatesIn\n'.format(ent, names.group(2)))
        elif names.group(1) == 'occupation_':
            fo.write('{}\t\t{}\t\ttypeOfPerson\n'.format(ent, names.group(2)))
        elif names.group(1) == 'selSexuality':
            fo.write('{}\t\t{}\t\thasSexuality\n'.format(ent, names.group(2)))
        elif names.group(1) == 'selGender':
            fo.write('{}\t\t{}\t\thasGender\n'.format(ent, names.group(2)))
        elif names.group(1) == 'selSex':
            fo.write('{}\t\t{}\t\thasSex\n'.format(ent, names.group(2)))
        elif names.group(1) == 'ethnic':
            fo.write('{}\t\t{}\t\tassociatedWithEthnicity\n'.format(ent, names.group(2)))
        elif names.group(1) == 'pLang':
            fo.write('{}\t\t{}\t\tusesPrimaryLanguage\n'.format(ent, names.group(2)))
        elif names.group(1) == 'lang_':
            fo.write('{}\t\t{}\t\tusesLanguage\n'.format(ent, names.group(2)))
        elif names.group(1) == 'hasInflu_':
            fo.write('{}\t\t{}\t\tinfluenced\n'.format(ent, names.group(2)))
        elif names.group(1) == 'wasInflu_':
            fo.write('{}\t\t{}\t\tinfluencedBy\n'.format(ent, names.group(2)))
        elif names.group(1) == 'createdBy':
            fo.write('{}\t\t{}\t\tcreatedBy\n'.format(ent, names.group(2)))
        elif names.group(1) == 'place':
            fo.write('{}\t\t{}\t\toriginatingCountry\n'.format(ent, names.group(2)))
        elif names.group(1) == 'relatedPlace_':
            fo.write('{}\t\t{}\t\tassociatedWithCountry\n'.format(ent, names.group(2)))

f.close()
fo.close()
