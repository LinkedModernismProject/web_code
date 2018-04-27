import os, re, sys
from unidecode import unidecode

newnames = []

#grabs all files in designated folder
def getFileList(directory):
    file_paths = []  # List which will store all of the full filepaths.
    # Walk the tree.
    for root, dirs, files in os.walk(directory, topdown=False):
        for filename in files:
            if re.search("\.docx$",filename):
                # Join the two strings in order to form the full filepath.
		newnames.append(filename)
                filepath = os.path.join(root, filename)
                file_paths.append(filepath)  # Add it to the list.
    return file_paths

file_list = getFileList(sys.argv[1])
i = 0

for x in file_list:
    y = x.replace(sys.argv[1],"")
    filename = unidecode(newnames[i])
    newfile = open("/usr/local/virtuoso-opensource/var/lib/virtuoso/vsp/weeklyRun/newData/newDOCX/" + filename,"w+")
    print(x)
    newfile.write(open(x,"r").read())
    i = i + 1
