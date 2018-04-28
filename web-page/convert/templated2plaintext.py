# -*- coding: utf-8 -*-

from bs4 import BeautifulSoup
import codecs
import os
import zipfile
from lxml import etree

#grabs all files in designated folder
def getFileList(directory):
    file_paths = []  # List which will store all of the full filepaths.
    # Walk the tree.
    for root, directories, files in os.walk(directory):
        for filename in files:
            if filename != ".DS_Store" and filename.endswith(".docx"):
                # Join the two strings in order to form the full filepath.
                filepath = os.path.join(root, filename)
                file_paths.append(filepath)  # Add it to the list.
    return file_paths



def _itertext(self, my_etree):
     """Iterator to go through xml tree's text nodes"""
     for node in my_etree.iter(tag=etree.Element):
         if _check_element_is(_check_element_is, node, 't'):
             yield (node, node.text)

def _check_element_is(self, element, type_char):
     word_schema = 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'
     return element.tag == '{%s}%s' % (word_schema,type_char)



def get_xml_tree(xml_string):
    return etree.fromstring(xml_string)

def get_word_xml(docx_filename):
    with open(docx_filename) as f:
        zip = zipfile.ZipFile(f)
        xml_content = zip.read('word/document.xml')
    #cont = get_xml_tree(xml_content)
    return xml_content



file_list = getFileList("/Users/brayden/Downloads/TrainingBatch2/")

for x in file_list:
    filedata = ''
    doc_xml = get_word_xml(x)
    soup = BeautifulSoup(str(doc_xml), 'lxml')
    temp = soup.find_all('w:t')
    for y in temp:
        filedata += y.text
    filedata.replace('\n','')
    filedata.replace(',','*****')
    temp1 = filedata.split('Your article')
    temp2 = temp1[1].split('Further reading')
    print(temp2[0])
    y = x.replace('.docx','.txt')
    y = y.replace('flat_entries/','flat_entries/complete/')
    structured_data = codecs.open(y,'w', 'utf-8')
    structured_data.write(temp2[0] + '\n')
    '''for node, txt in _itertext(_itertext, doc_xml):
        txt.decode('iso-8859-1').encode('utf-8')
        txt.replace('\n','')
        txt.replace(',','****')
        structured_data.write(txt)
            x.encode('utf-8')
            x.replace(',','')
            x.replace(' ','_')
            structured_data.write(x + ',')

        '''
    structured_data.write('\n')




#truncates data from proper templated format, template specified in root directory
def truncateFile(file_name):
    document = textract.process(file_name, method='docx')
    print(document)


'''    doc_text = temp.read()
    doc_text = doc_text.split('Your article')
    doc_text[0].replace('\n','')
    doc_text[0].replace(',','****')
    structured_data.write(doc_text[0] + '\n')'''

'''
document = Document(file_name)
for table in document.tables:
    for row in table.rows:
        for cell in row.cells:
            for paragraphs in cell.paragraphs:
                temp = paragraphs.text
                temp = temp.replace(',','*****')
                temp = temp.replace('\n','')
                structured_data.write(temp + ',')
structured_data.write('\n')
'''
