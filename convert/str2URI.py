import os, re
from unidecode import unidecode

rdf_file = open("/Users/brayden/Documents/web_code/convert/bestDataB.ttl",'r')
write_file = open("/Users/brayden/Documents/web_code/convert/bestDataC.ttl",'w+')
string_dict = {}
i = 0




def string_replace(predicate, file_object, end_piece):
    file_object = file_object.replace(';','')
    file_object = file_object.replace(',','')
    file_object = file_object.replace('.','')
    file_object = file_object.replace('"','')
    file_object = file_object.replace('(','')
    file_object = file_object.replace(')','')
    file_object = file_object.replace("'",'_')
    file_object = file_object.replace('!','')
    file_object = file_object.replace('&','and')
    file_object = file_object.replace('/','')
    file_object = file_object.replace('[','')
    file_object = file_object.replace(']','')
    file_object = file_object.replace('+','and')
    file_object = file_object.replace('?','')
    file_object = file_object.replace('>','')
    file_object = file_object.replace('<','')
    file_object = file_object.replace('»','')
    file_object = file_object.replace('`','')
    file_object = file_object.replace('=','_')
    file_object = file_object.replace('#','')
    file_object = file_object.replace('-','')



    file_object = unidecode(file_object)
    if(file_object == 'no'):
        print(predicate)
        print(file_object)
        write_file.write(predicate + ' "' + file_object + '"' + ' ' + end_piece)
        return
    elif(file_object == 'yes'):
        print(predicate)
        print(file_object)
        write_file.write(predicate + ' "' + file_object + '"' + ' ' + end_piece)
        return
    elif(file_object == 'No'):
        print(predicate)
        print(file_object)
        write_file.write(predicate + ' "' + file_object + '"' + ' ' + end_piece)
        return
    elif(file_object == 'Yes'):
        print(predicate)
        print(file_object)
        write_file.write(predicate + ' "' + file_object + '"' + ' ' + end_piece)
        return
    elif(re.search('VisualArts$', predicate) != None):
        write_file.write(predicate + ' pref0:' + file_object.strip().replace(' ','_') + ' ' + end_piece)
    elif(re.search('founderOrLeader$', predicate) != None):
        write_file.write(predicate + ' pref0:' + file_object.strip().replace(' ','_') + ' ' + end_piece)
    elif(re.search('membersOrFiguresAssociatedWithGroupOrMovement$', predicate) != None):
        write_file.write(predicate + ' pref0:' + file_object.strip().replace(' ','_') + ' ' + end_piece)
    elif(re.search('worksOrEventsMostCommonlyAssociatedWithGroupOrMovement$', predicate) != None):
        write_file.write(predicate + ' pref0:' + file_object.strip().replace(' ','_') + ' ' + end_piece)
    elif(re.search('typeOfPerson$', predicate) != None):
        write_file.write(predicate + ' pref0:' + file_object.strip().replace(' ','_') + ' ' + end_piece)
    elif(re.search('correspondedWith$', predicate) != None):
        write_file.write(predicate + ' pref0:' + file_object.strip().replace(' ','_') + ' ' + end_piece)
    elif(re.search('knows$', predicate) != None):
        write_file.write(predicate + ' pref0:' + file_object.strip().replace(' ','_') + ' ' + end_piece)
    elif(re.search('associatedWithTechnique$', predicate) != None):
        write_file.write(predicate + ' pref0:' + file_object.strip().replace(' ','_') + ' ' + end_piece)
    elif(re.search('associatedMovement$', predicate) != None):
        write_file.write(predicate + ' pref0:' + file_object.strip().replace(' ','_') + ' ' + end_piece)
    elif(re.search('groupOrMovement$', predicate) != None):
        write_file.write(predicate + ' pref0:' + file_object.strip().replace(' ','_') + ' ' + end_piece)
    elif(re.search('createdBy$', predicate) != None):
        write_file.write(predicate + ' pref0:' + file_object.strip().replace(' ','_') + ' ' + end_piece)
    elif(re.search('influencedBy$', predicate) != None):
        write_file.write(predicate + ' pref0:' + file_object.strip().replace(' ','_') + ' ' + end_piece)
    elif(re.search('associatedWithCountry$', predicate) != None):
        write_file.write(predicate + ' pref0:' + file_object.strip().replace(' ','_') + ' ' + end_piece)
    elif(re.search('originatingCountry$', predicate) != None):
        write_file.write(predicate + ' pref0:' + file_object.strip().replace(' ','_') + ' ' + end_piece)
    elif(re.search('associatedWithRegion$', predicate) != None):
        write_file.write(predicate + ' pref0:' + file_object.strip().replace(' ','_') + ' ' + end_piece)
    elif(re.search('groupOrMovementInternationalOrParochial$', predicate) != None):
        write_file.write(predicate + ' pref0:' + file_object.strip().replace(' ','_') + ' ' + end_piece)
    elif(re.search('associatedWithEmpire$', predicate) != None):
        write_file.write(predicate + ' pref0:' + file_object.strip().replace(' ','_') + ' ' + end_piece)
    elif(re.search('associatedWithCities$', predicate) != None):
        write_file.write(predicate + ' pref0:' + file_object.strip().replace(' ','_') + ' ' + end_piece)
    elif(re.search('associatedWithVenues$', predicate) != None):
        write_file.write(predicate + ' pref0:' + file_object.strip().replace(' ','_') + ' ' + end_piece)
    elif(re.search('associatedWithEthnicity$', predicate) != None):
        write_file.write(predicate + ' pref0:' + file_object.strip().replace(' ','_') + ' ' + end_piece)
    elif(re.search('associatedWithLiterature$', predicate) != None):
        write_file.write(predicate + ' pref0:' + file_object.strip().replace(' ','_') + ' ' + end_piece)
    elif(re.search('NonFictionOrConceptOrIdeaTypeOfWriting$', predicate) != None):
        write_file.write(predicate + ' pref0:' + file_object.strip().replace(' ','_') + ' ' + end_piece)
    elif(re.search('usesLanguage$', predicate) != None):
        write_file.write(predicate + ' pref0:' + file_object.strip().replace(' ','_') + ' ' + end_piece)
    elif(re.search('usesPrimaryLanguage$', predicate) != None):
        write_file.write(predicate + ' pref0:' + file_object.strip().replace(' ','_') + ' ' + end_piece)
    elif(re.search('hasAlias$', predicate) != None):
        write_file.write(predicate + ' pref0:' + file_object.strip().replace(' ','_') + ' ' + end_piece)
    elif(re.search('seeAlso$', predicate) != None):
        write_file.write(predicate + ' pref0:' + file_object.strip().replace(' ','_') + ' ' + end_piece)
    elif(re.search('creatorOf$', predicate) != None):
        write_file.write(predicate + ' pref0:' + file_object.strip().replace(' ','_') + ' ' + end_piece)
    elif(re.search('createdByIndirect$', predicate) != None):
        write_file.write(predicate + ' pref0:' + file_object.strip().replace(' ','_') + ' ' + end_piece)
    elif(re.search('influencedByDifferentKind$', predicate) != None):
        write_file.write(predicate + ' pref0:' + file_object.strip().replace(' ','_') + ' ' + end_piece)
    elif(re.search('influenced$', predicate) != None):
        write_file.write(predicate + ' pref0:' + file_object.strip().replace(' ','_') + ' ' + end_piece)
    elif(re.search('initiallyAppearedInVenue$', predicate) != None):
        write_file.write(predicate + ' pref0:' + file_object.strip().replace(' ','_') + ' ' + end_piece)
    else:
        write_file.write(predicate + ' "' + file_object + '"' + ' ' + end_piece)
    return
#    file_line = x.readline()


for x in rdf_file:
    split_line = re.split('" | "',x)
    string_dict[i] = split_line
    i = i + 1
    if(len(split_line) <= 1):
        tmp = split_line[0].replace('"','')
        tmp = tmp.replace(',','')
        write_file.write(unidecode(tmp))
    elif(len(split_line) > 1):
        if(split_line[1] != 'yes'):
            if(split_line[1] != 'No'):
                if(split_line[1] != 'no'):
                    if(split_line[1] != 'Yes'):
                        string_replace(split_line[0],split_line[1],split_line[2])
                    else:
                        string_replace(split_line[0], split_line[1], split_line[2])
                else:
                    string_replace(split_line[0], split_line[1], split_line[2])
            else:
                string_replace(split_line[0], split_line[1], split_line[2])
        else:
            string_replace(split_line[0], split_line[1], split_line[2])
