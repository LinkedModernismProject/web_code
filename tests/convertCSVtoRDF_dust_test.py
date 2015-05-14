#!/usr/bin/env python2.7
'''
  Converting CSV files to JSON 

2015 Feburary 23

----------------------------------------------------
By Ashlin Richardson (richardson.ashlin@gmail.com) 
Developer, Linked Modernisms
University of Victoria 
----------------------------------------------------

- In the folder surveyMonkey/Data_All_150205/CSV there are seven .csv files:
  Sheet_1.csv-- Sheet_7.csv

- Re-saved csv files from EXCEL format (xls) data.
- Replaced (in excel) any commas with **********. 
- The ********** delimiter is replaced with ',' again, after reading. 
- Input text encoding is tested (it is ISO-8859-1).
- Data converted to ('utf8' encoding) when output in JSON format. 
- First two lines of CSV file needed to be mashed (to create field names).
- Special fields (col >=9) with names not {Other*, Response*, and Open*} 
   were required to contain nothing, or be equal to the name of the field. 
- All records passed the above test. 

color Routines:
'''

'''
Working on converting page to turtle or N-Triples or N3. Then using RDFConvert to get into proper format.
  Had to change a > symbol in the mytest.nt created as it interferred with the format for .nt files
'''
'''
Possible improvements:
  Get rid of #Response and other forms(Open-ended Response) etc.?
  Maybe fix in the 20150309Workbookv3_ontology2 column AK ro 2
'''


import os
def MAGENTA():
    if(os.name!='posix'):
        return(str(""));
    else:
        return('\033[95m');
def BLUE():
    if(os.name!='posix'):
        return(str(""));
    else:
        return('\033[94m');
def GREEN():
    if(os.name!='posix'):
        return(str(""));
    else:
        return('\033[92m');
def YELLOW():
    if(os.name!='posix'):
        return(str(""));
    else:
        return('\033[93m');
def RED():
    if(os.name!='posix'):
        return(str(""));
    else:
        return('\033[91m');
def DEFAULT(): #return to normal 
    if(os.name!='posix'):
        return str("");
    else:
         return('\033[0m');


#142.104.52.1142.104.52.1

import csv, json, copy

def force_decode(string, codecs=['ISO-8859-1','utf8', 'cp1252','ascii']):
    for i in codecs:#142.104.52.1
        try:
            a = string.decode(i)
            print("Was able to decode with codec "+str(i));
            return(a.encode('utf8'));
        except:
            pass
    print("Error: was not able to decode with either codec");
    import sys
    sys.exit(1);

def fixNulls(csvFileName): #based on http://stackoverflow.com/questions/4166070/python-csv-error-line-contains-null-byte
  fi = open(csvFileName, 'rb')
  data = fi.read()
  fi.close()
  newCSVFileName = 'new'+csvFileName;
  fo = open(newCSVFileName, 'wb')
  newData = ( (data.replace('\x00', ' ')));#.encode("UTF-8") )
  newData = force_decode(newData);
  fo.write(newData);
  fo.close();#len(responseNames)
  return(newCSVFileName);


csvFile = "20150309Workbookv3_ontology2.csv";
csvfile = open(csvFile,'rU');#'file.csv', 'r')
reader = csv.reader( csvfile, dialect=csv.excel_tab);# fieldnames)
myRows = { };
fieldNames = [ ]; #origFieldNames[i] = { } ; origResponseNames[i] = { } ;
fieldNameForCol = { } ; #142.104.52.1
responseNames = [ ];
nCol = 0;
nCol0 = 0;
j=0; 
for row in reader:
  myRow = copy.deepcopy(row);#row[0].split(",");
  myRow = myRow[0].split(',');
  for kk in range(0,len(myRow)):
    myRow[kk] = (myRow[kk]).replace('**********',',');
  if( j==1):
    responseNames = copy.deepcopy(myRow);
  elif( j==0):
    #fieldNames = copy.deepcopy(myRow);  
    #origFieldNames = copy.deepcopy(myRow);
    #nCol =nCol0= len(fieldNames);
    #print(RED()+"Column header("+str(len(fieldNames))+"):"+str(fieldNames));
    #elif(j==0): 
    #    responseNames = copy.deepcopy(myRow);
    fieldNames = copy.deepcopy(myRow);
  else:
    myRows[j]=myRow;
  j+=1;  

#print(BLUE()+str(fieldNames))
#print(GREEN()+str(responseNames));

mod_uvic = '<http://modernism.uvic.ca/metadata#'  #Just cleaning up for make print line easier to read
myNames = { } 
for i in myRows:
  row = myRows[i];
  myName = row[0];
  for j in range(1,len(row)):
    if( (str(row[j]).strip())!=''):
      try:
        triple = [ myName, responseNames[j], row[j]]
        #Needs a space before ".", but still looking at better format for turtle, starting with N-Triples first
        if str(triple[1]) == str(triple[2]):
          print mod_uvic+ str(triple[0])+'> '+ mod_uvic + str(triple[1]) +'> "True" .'
        else:
          print mod_uvic+ str(triple[0])+'> '+ mod_uvic + str(triple[1]) +'> "' + str(triple[2])+'" .'
        #print(  mod_uvic+ str(triple[0])+'> '+ mod_uvic + str(triple[1]) +'> ' + mod_uvic + str(triple[2])+'> .' )

        #Tests
        #if i<10:
        #  if str(triple[1]) == str(triple[2]):
        #    print 'True'
        #  else:
        #    print 'False'

      except:
        pass
      myNames[myName]=1;

#========================================================================
nameList = [ ] 
for name in myNames:
  nameList.append(name);

#print nameList

import os,sys
sys.exit(1);


pfx = "Sheet_"
myFileNames = [ ];
myFileNRows = { } ;

numberOfErrors= 0;
numberOfNonErrors=0;

myData = [ ];


'''
Note 1:  Started with code by BeanBagKing at http://stackoverflow.com/questions/19697846/python-csv-to-json

Note 2: Had to apply this technique to remove "null" characters... 
  http://stackoverflow.com/questions/4166070/python-csv-error-line-contains-null-byte

otherwise we would get an error like:
  Traceback (most recent call last):
    File "./convertCSVtoJSON.py", line 123, in <module>
      for row in reader:
  _csv.Error: line contains NULL byte
'''

myDataI = { };

origFieldNames ={ };
origResponseNames= { } ;
for i in range(0,7):
  myDataI[i] = { };
  fPfx      = "Sheet_"+str(i+1)+".";
  myFileNames.append( fPfx);
  csvFile   = fPfx+"csv"; 
  csvFile   = fixNulls(csvFile);
  jsnFile   = fPfx+"json";

  csvfile = open(csvFile,'rU');#'file.csv', 'r')
  reader = csv.reader( csvfile, dialect=csv.excel_tab);# fieldnames)
  myRows = { };
  fieldNames = [ ]; origFieldNames[i] = { } ; origResponseNames[i] = { } ;
  fieldNameForCol = { } ; 
  responseNames = [ ];
  nCol = 0;
  nCol0 = 0;
  j=0; 
  for row in reader:
    myRow = copy.deepcopy(row);#row[0].split(",");
    myRow = myRow[0].split(',');
    for kk in range(0,len(myRow)):
      myRow[kk] = (myRow[kk]).replace('**********',',');
    if( j==0):
      fieldNames = copy.deepcopy(myRow);  
      origFieldNames[i] = copy.deepcopy(myRow);
      nCol =nCol0= len(fieldNames);
      print(RED()+"Column header("+str(len(fieldNames))+"):"+str(fieldNames));
    elif(j==1):
      responseNames = copy.deepcopy(myRow);
      origResponseNames[i] = copy.deepcopy(myRow);
      print(MAGENTA()+"Column header("+str(len(responseNames))+"):"+str(responseNames));#fieldNames));
      nCol = len(responseNames);#max(nCol,len(responseNames));  
      if( nCol > nCol0):
        print("Error: new header length was longer than old header length.");
        import sys;
        sys.exit(1);
      for k in range(9,len(responseNames)):#nCol0): 
        #print(str(i))
        fieldNames[k] = responseNames[k];
    else:
      pass
    myRows[j] = copy.deepcopy(myRow);
    j+=1;
  nRows = j;#copy.deepcopy(j);
  j = 0;
  myFileNRows[ fPfx ] = nRows;
  myFieldNames = [ ] 
  for fieldName in fieldNames:
    if(fieldName.strip()!=''):
      if( j>8):
        print (RED() + str(j)+",")+(GREEN() + str(fPfx)) + (BLUE()+str(fieldName))
      myFieldNames.append(fieldName);
      fieldNameForCol[ j ] = fieldName; 
    j+=1;
  j=0; 
  for j in range(2,nRows):
    row = myRows[j]; 
    dataElement = { };
    print(GREEN()+str(row));
    errorThisRow = False;
    nCol =len(fieldNames);
    for k in range(0,min(nCol, len(row))):
      if( fieldNames[k] ==''):
        if( row[k]!=''):
          print(RED()+"---->ERROR(): row("+str(j)+"),col("+str(k)+")");
          print(RED()+"\t\t<--"+row[k])
          errorThisRow = True;
        else:
          pass
      else:
        if( k>=9 ):
          try:
            #if( row[i] == 'Portuguese'):
            #  print("Found "+str(row[i]));
            #  print("FIELDNAMES:"+str(fieldNames[i]));
            #  sys.exit(1);
            if( row[k]!='' and ((fieldNames[k])[:5]!='Other') and ((fieldNames[k])[:4]!='Open') and ((fieldNames[k])[:8]!='Response')    ):
              if( fieldNames[k]!=row[k]):
                errorThisRow = True;
                print("Row entry was("+str(row[k])+"), field Name was("+str(fieldNames[k]))
          except:
            pass
      if( fieldNames[k]!='' and row[k]!=''):
        dataElement[fieldNames[k]] = row[k];
    if(errorThisRow):
      print(RED()+str("Error this row!!!!!!!!!"));
      print( BLUE()+str(fieldNames));
      numberOfErrors+=1;
    else:
      numberOfNonErrors+=1;
      myData.append( dataElement);
      print str(i)+","+str(j)
      (myDataI[i])[j] = copy.deepcopy(dataElement);


  print(RED()+"Column header:"+str(fieldNames));
  print(GREEN()+"number of Columns"+str(nCol));
  #================================================
  csvfile.close();
  print("NROW==>"+RED()+str(nRows)+GREEN()+","+"----------------------------------------------------")



for fileName in myFileNames:
  print(GREEN()+str(fileName)+RED()+","+BLUE()+str(myFileNRows[fileName]));
print fieldNames
print("Number of Errors:", numberOfErrors);
print("Rows without Err:", numberOfNonErrors);

import io
with io.open('data.json', 'w', encoding='utf-8') as f:
  f.write( unicode(json.dumps(myData)).replace(u'**********',u','));#json.dump( myData, f);#outfile);
  f.close();

jsonData = json.loads( open("data.json","r").read() );

for d in jsonData:
  print(GREEN()+str(d));



joinData = { } 
for j in range(2,nRows):
  joinData[j] = { }; #add a dictionary element for this row.
  for i in range(0,7):
    try:
      d0 = (myDataI[i])[j] #print x0    
      di = -1;
      for d in d0:
        di+=1;
        if d in joinData[j]:
          #print(GREEN()+"Warning: key was already present in record");
          if(str(d0[d])!=str((joinData[j])[d])):
            print(RED()+"Warning-- duplicate keys had non-matching values-- key="+str(d)+"-->"+str(d0[d]) +","+ str((joinData[j])[d])) 
            print(GREEN()+"-----"+str(  (  ( origFieldNames[i]).split(","))[di])+","+str(  ( (origResponseNames[i]).split(","))[di]))
            #import sys; sys.exit(1);
        (joinData[j])[d] = d0[d];
    except: 
      print(RED()+"Error: i,j=("+str(i)+","+str(j));
      #import sys; sys.exit(1);
print(MAGENTA()+"2--"+str(nRows)+" rows processed for all 7 files"+GREEN())
print(MAGENTA()+"2--"+str(nRows)+" rows processed for all 7 files"+GREEN()+"-- there were no duplicate keys. See above for warnings. Need to check consistency--")

#for j in range(2,nRows):
#  print joinData[j]

for i in range(0,7): 
  '''print out first two rows of csv'''
  print RED()+str(origFieldNames[i])
  print GREEN()+str(origResponseNames[i])

'''---- do not use ID (row index) as identifier. Use the ANSWER to the long-format question string.. (check for consistency)... '''
'''---- delete A through I ----- do not expose... ''' 
''' -- do not need question at all...?? ---''' 



'''
 (1)   "Columns should be relabeled corresponding to lexicon of ontology.. JSON should be instance of ontology..." 
   instead of "design"... say, (subject, object, predicate)..."is a", "design", "T/F"

   SPARQL... show me all the subjects for which  predicate "is a" corresponds to object.. 
'''

''' 
  (2) for binary questions, do you want true/false rather than yes/no.... answer this from teh ontology.. GroupOrMovement,True/False... (translate Yes/No into True/False).. 

  ( ) need to make a translation table between the col. names that are there, and the ontology names...  (critical/controlled vocabulary).... I.E., need to translate the QUESTIONS into vocabulary (object-predicate relationship) from the Ontology... 

isa,object .... isa, installation.... associatedWith,dance.. associatedwith,magic... 

  (2) for the open-ended/ yes-no questions, do we make the "object" the actual "question"..

  ( ) change QUESTIONS....  

'''
