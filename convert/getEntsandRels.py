import os, re
from bs4 import BeautifulSoup
from unidecode import unidecode


#grabs all files in designated folder
def getFileList(directory):
    file_paths = []  # List which will store all of the full filepaths.
    # Walk the tree.
    for root, directories, files in os.walk(directory):
        for filename in files:
            if filename != ".DS_Store":
                # Join the two strings in order to form the full filepath.
                filepath = os.path.join(root, filename)
                file_paths.append(filepath)  # Add it to the list.
    return file_paths

file_list = getFileList("/Users/brayden/Documents/parsing/processed/")
newfile = open("/Users/brayden/Documents/entsAndRels.txt","w")

def removeUselessInfo(replaceString):
    replaceString = unidecode(replaceString)
    if re.match(',',replaceString):
        return replaceString.replace(', ','')
    elif re.match('\.',replaceString):
        return replaceString.replace('. ','')
    elif re.match('-',replaceString):
        replaceString = re.sub("\-...\-\s",'',replaceString)
        return replaceString
    elif re.match("'",replaceString):
        replaceString = replaceString.replace("' ",'')
        return replaceString.replace("'s ",'')
    else:
        return replaceString


for x in file_list:
    soup = BeautifulSoup(open(x,'r'),'xml')
    entity_dict = {}
    for sentences in soup.findAll('sentence'):
        arrayOfWords = []
        for tokens in sentences.findAll('tokens'):
            for token in tokens.findAll('token'):
                for words in token.findAll('word'):
                    newWord = words.prettify().replace('<word>','')
                    newWord = newWord.replace('</word>','')
                    newWord = newWord.replace(' ','')
                    newWord = newWord.replace('\n','')
                    arrayOfWords.append(newWord)
                    #Reminder*********** Offset array value by 1 for sentence comparison
        for machRead in sentences.findAll('MachineReading'):
            for entities in machRead.findAll('entities'):
                for entity in entities.findAll('entity'):
                    for span in entity.findAll('span'):
                        startNum = int(span['start']) - 1
                        endNum = int(span['end']) - 1
                        if(endNum - startNum != 1):
                            print(endNum - startNum)
                        entityTypeArray = entity.contents
                        entityType = entityTypeArray[0].split('\n')
                        entityType = entityType[0]
                        #print(entityType)
                        #print(arrayOfWords[startNum] + ' ' + arrayOfWords[endNum])

            for relations in machRead.findAll('relations'):
                for relation in relations.findAll('relation'):
                    wrongType = ''
                    currentRelation = ''
                    for arguments in relation.findAll('arguments'):
                        for entity in arguments.findAll('entity'):
                            entityTypeArray = entity.contents
                            entityType = entityTypeArray[0].split('\n')
                            entityType = entityType[0]
                            if entityType is 'O':
                                wrongType = 'O'
                                break
                            for span in entity.findAll('span'):
                                startNum = int(span['start']) - 1
                                endNum = int(span['end']) - 1
                                fullEntity = arrayOfWords[startNum] + ' ' + arrayOfWords[endNum]
                                fullEntity = removeUselessInfo(fullEntity)
                                currentRelation += fullEntity + '\t\t'
                    currentRelation += relation.contents[0].replace(' ','')
                #if anything is equal to O, go to next relation. Otherwise print the relation
                    if wrongType is 'O':
                        break
                    else:
                        newfile.write(unidecode(currentRelation))
