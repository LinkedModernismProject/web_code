import os, re
from unidecode import unidecode

rdf_file = open("/Users/brayden/Documents/web_code/convert/bestDataProductionDec.ttl",'r')
write_file = open("/Users/brayden/Documents/web_code/convert/bestDataProductionDoS.ttl",'w+')
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
    file_object = file_object.replace('`','')
    file_object = file_object.replace('=','_')
    file_object = file_object.replace('-','_')
    file_object = file_object.replace('#','')
    file_object = file_object.replace(':','')

    file_object = unidecode(file_object)
    if(file_object == 'no'):
        return
    elif(file_object == 'yes'):
        write_file.write(predicate + ' "' + file_object + '"' + ' ' + end_piece)
        return
    elif(file_object == 'No'):
        return
    elif(re.search('hasBirthdate$', predicate) != None):
        write_file.write(predicate + ' pref0:' + file_object.strip().replace(' ','_') + ' ' + end_piece)
    elif(re.search('terminatesIn$', predicate) != None):
        write_file.write('\tpref1:terminatesIn pref0:' + file_object.strip().replace(' ','_') + ' ' + end_piece)
    elif(re.search('originatedInCountry$', predicate) != None):
        write_file.write(predicate + ' pref0:' + file_object.strip().replace(' ','_') + ' ' + end_piece)
    elif(re.search('hasGender$', predicate) != None):
        write_file.write(predicate + ' pref1:' + file_object.strip().replace(' ','_') + ' ' + end_piece)
    elif(re.search('studiedAt$', predicate) != None):
        write_file.write(predicate + ' pref0:' + file_object.strip().replace(' ','_') + ' ' + end_piece)
    elif(re.search('hasSex$', predicate) != None):
        write_file.write(predicate + ' pref1:' + file_object.strip().replace(' ','_') + ' ' + end_piece)
    elif(re.search('hasSexuality$', predicate) != None):
        write_file.write(predicate + ' pref1:' + file_object.strip().replace(' ','_') + ' ' + end_piece)
    elif(re.search('PerformingArts$', predicate) != None):
        write_file.write(predicate + ' pref0:' + file_object.strip().replace(' ','_') + ' ' + end_piece)
    elif(re.search('^\tpref1:is', predicate) != None):
        write_file.write('\trdf:type ' + 'pref1:' + predicate.replace('\tpref1:is','') + ' ' + end_piece)
    elif(re.search('VisualArts$', predicate) != None):
        write_file.write(predicate + ' pref1:' + file_object.strip().replace(' ','_') + ' ' + end_piece)
    elif(re.search('flourishesIn$', predicate) != None):
        write_file.write(predicate + ' pref0:' + file_object.strip().replace(' ','_') + ' ' + end_piece)
    elif(re.search('inspiredBy$', predicate) != None):
        write_file.write(predicate + ' pref0:' + file_object.strip().replace(' ','_') + ' ' + end_piece)
    elif(re.search('affiliatedWith$', predicate) != None):
        write_file.write(predicate + ' pref0:' + file_object.strip().replace(' ','_') + ' ' + end_piece)
    elif(re.search('founderOrLeader$', predicate) != None):
        write_file.write(predicate + ' pref0:' + file_object.strip().replace(' ','_') + ' ' + end_piece)
    elif(re.search('founderOf$', predicate) != None):
        write_file.write(predicate + ' pref0:' + file_object.strip().replace(' ','_') + ' ' + end_piece)
    elif(re.search('hasNationality$', predicate) != None):
        write_file.write(predicate + ' pref0:' + file_object.strip().replace(' ','_') + ' ' + end_piece)
    elif(re.search('membersOrFiguresAssociatedWithGroupOrMovement$', predicate) != None):
        write_file.write('\tpref1:associatedWith pref0:' + file_object.strip().replace(' ','_') + ' ' + end_piece)
    elif(re.search('worksOrEventsMostCommonlyAssociatedWithGroupOrMovement$', predicate) != None):
        write_file.write('\tpref1:associatedWith pref0:' + file_object.strip().replace(' ','_') + ' ' + end_piece)
    elif(re.search('typeOfPerson$', predicate) != None):
        write_file.write(predicate + ' pref1:' + file_object.strip().replace(' ','_') + ' ' + end_piece)
    elif(re.search('correspondedWith$', predicate) != None):
        write_file.write(predicate + ' pref0:' + file_object.strip().replace(' ','_') + ' ' + end_piece)
    elif(re.search('knows$', predicate) != None):
        write_file.write(predicate + ' pref0:' + file_object.strip().replace(' ','_') + ' ' + end_piece)
    elif(re.search('associatedWithTechnique$', predicate) != None):
        write_file.write(predicate + ' pref0:' + file_object.strip().replace(' ','_') + ' ' + end_piece)
    elif(re.search('associatedMovement$', predicate) != None):
        write_file.write(predicate + ' pref0:' + file_object.strip().replace(' ','_') + ' ' + end_piece)
    elif(re.search('^\tpref1:groupOrMovement', predicate) != None):
        if(file_object.strip() == 'Yes'):
            write_file.write('\trdf:type pref1:groupOrMovement ' + end_piece)
        elif(file_object.strip() == 'International'):
            write_file.write('\trdf:type pref1:groupOrMovement ' + end_piece)
        elif(file_object.strip() == 'Parochial'):
            write_file.write('\trdf:type pref1:groupOrMovement ' + end_piece)
        else:
            write_file.write('\tpref1:groupOrMovement pref0:' + file_object.strip().replace(' ','_') + ' ' + end_piece)
    elif(re.search('createdBy$', predicate) != None):
        write_file.write(predicate + ' pref0:' + file_object.strip().replace(' ','_') + ' ' + end_piece)
    elif(re.search('influencedBy$', predicate) != None):
        write_file.write(predicate + ' pref0:' + file_object.strip().replace(' ','_') + ' ' + end_piece)
    elif(re.search('artifactNature$', predicate) != None):
        write_file.write('\tpref1:hasType pref1:' + file_object.strip().replace(' ','_') + ' ' + end_piece)
    elif(re.search('associatedWithCountry$', predicate) != None):
        write_file.write(predicate + ' pref0:' + file_object.strip().replace(' ','_') + ' ' + end_piece)
    elif(re.search('originatingCountry$', predicate) != None):
        write_file.write(predicate + ' pref0:' + file_object.strip().replace(' ','_') + ' ' + end_piece)
    elif(re.search('associatedWithRegion$', predicate) != None):
        write_file.write(predicate + ' pref0:' + file_object.strip().replace(' ','_') + ' ' + end_piece)
    elif(re.search('associatedWithEmpire$', predicate) != None):
        write_file.write(predicate + ' pref0:' + file_object.strip().replace(' ','_') + ' ' + end_piece)
    elif(re.search('type$', predicate) != None):
        write_file.write(predicate + ' pref1:' + file_object.strip().replace(' ','_') + ' ' + end_piece)
    elif(re.search('associatedWithCities$', predicate) != None):
        write_file.write(predicate + ' pref0:' + file_object.strip().replace(' ','_') + ' ' + end_piece)
    elif(re.search('associatedWithVenues$', predicate) != None):
        write_file.write(predicate + ' pref0:' + file_object.strip().replace(' ','_') + ' ' + end_piece)
    elif(re.search('associatedWithEthnicity$', predicate) != None):
        write_file.write(predicate + ' pref0:' + file_object.strip().replace(' ','_') + ' ' + end_piece)
    elif(re.search('associatedWithLiterature$', predicate) != None):
        write_file.write(predicate + ' pref0:' + file_object.strip().replace(' ','_') + ' ' + end_piece)
    elif(re.search('associatedWith$', predicate) != None):
        write_file.write(predicate + ' pref0:' + file_object.strip().replace(' ','_') + ' ' + end_piece)
    elif(re.search('NonFictionOrConceptOrIdeaTypeOfWriting$', predicate) != None):
        write_file.write('\tpref1:typeOfWriting pref0:' + file_object.strip().replace(' ','_') + ' ' + end_piece)
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
        write_file.write('\tpref1:influencedBy pref0:' + file_object.strip().replace(' ','_') + ' ' + end_piece)
    elif(re.search('influencedDifferentKind$', predicate) != None):
        write_file.write('\tpref1:influenced pref0:' + file_object.strip().replace(' ','_') + ' ' + end_piece)
    elif(re.search('influenced$', predicate) != None):
        write_file.write(predicate + ' pref0:' + file_object.strip().replace(' ','_') + ' ' + end_piece)
    elif(re.search('initiallyAppearedInVenue$', predicate) != None):
        write_file.write(predicate + ' pref0:' + file_object.strip().replace(' ','_') + ' ' + end_piece)
    elif(re.search('associatedWithJudaism$', predicate) != None):
        write_file.write(predicate + ' pref0:' + file_object.strip().replace(' ','_') + ' ' + end_piece)
    elif(re.search('Music$', predicate) != None):
        write_file.write(predicate + ' pref0:' + file_object.strip().replace(' ','_') + ' ' + end_piece)
    elif(re.search('associatedWithChristianity$', predicate) != None):
        write_file.write(predicate + ' pref0:' + file_object.strip().replace(' ','_') + ' ' + end_piece)
    elif(re.search('typeOfEvent$', predicate) != None):
        write_file.write('\tpref1:hasType pref0:' + file_object.strip().replace(' ','_') + ' ' + end_piece)
    elif(re.search('natureOfEvent$', predicate) != None):
        write_file.write('\tpref1:hasNature pref0:' + file_object.strip().replace(' ','_') + ' ' + end_piece)
    elif(re.search('associatedWithOtherReligion$', predicate) != None):
        write_file.write(predicate + ' pref0:' + file_object.strip().replace(' ','_') + ' ' + end_piece)
    elif(re.search('timeOfForgerySinceInitialAppearance$', predicate) != None):
        return
    elif(re.search('timeToTranslation$', predicate) != None):
        return
    elif(re.search('translationTargetLanguage$', predicate) != None):
        write_file.write('\tpref1:translatedInto pref0:' + file_object.strip().replace(' ','_') + ' ' + end_piece)
    elif(re.search('Is_your_term_an_$', predicate) != None):
        write_file.write(predicate + ' pref0:' + file_object.strip().replace(' ','_') + ' ' + end_piece)
    elif(re.search('worksAlludedToOrReferredTo$', predicate) != None):
        write_file.write('\tpref1:refersDirectly pref0:' + file_object.strip().replace(' ','_') + ' ' + end_piece)


    elif(re.search('includesParatext$', predicate) != None):
        return
    else:
        write_file.write(predicate + ' "' + file_object + '"' + ' ' + end_piece)
    return
#    file_line = x.readline()


for x in rdf_file:
    split_line = re.split('" | "',x)
    string_dict[i] = split_line
    i = i + 1
    if(len(split_line) <= 1):
        replaceBad = split_line[0].split("#")
        if(replaceBad[0] != '\n'):
            noBadCharacters = replaceBad[1].replace('.','')
            noBadCharacters = noBadCharacters.replace(':','')
            noBadCharacters = noBadCharacters.replace(',','')
            noBadCharacters = noBadCharacters.replace('"','')
            print(noBadCharacters)
            tmp = replaceBad[0] + '#' + noBadCharacters
            write_file.write(unidecode(tmp))
        else:
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
