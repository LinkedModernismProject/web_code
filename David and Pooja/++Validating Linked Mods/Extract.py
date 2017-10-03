import nltk
import re
def Extract_bk():
	try:
		file_object = open('machineLearningJanuary.txt', "r")
	except IOError:
		print "cant open file"
	file = open('result.txt', "a")
	#print lines
	# lines = file_object.readline()
	while True:
		lines=file_object.readline()
		if not lines:
			break
		if re.match(r'^\d+\s\d+\s[a-zA-Z]+', lines.strip()):
			# print lines
			file.write(lines + '\n')
			
	file_object.close()
	file.close()

def Match_bk():
	f1 = open('machineLearningJanuary.txt', "r")
	f2 = open('result.txt', "r+")
	f3 = open('fresult.txt', "a")
	dict = {}

	# line2 = ""
	while True:
		line1 = f1.readline()
		if not line1:
			break
		
		if not line1 in ['\n', '\r\n']:
			if len(line1.split())==6 and line1.split()[1] != 'O':
			#print line1.strip()	
				dict[line1.split()[2]] = line1.split()[5]
	# print dict
	# cnt = 0
	for line2 in f2:
		if line2.strip():
			line2 = line2.strip()
			if line2.split()[0] in dict.keys() and line2.split()[1] in dict.keys():
				cnt=cnt+1
				# pass
				#print line2.split()[0], dict[line2.split()[0]]
				# print line2
				line2 = line2.replace(line2.split()[0], dict[line2.split()[0]])
				line2 = line2.replace(line2.split()[1], dict[line2.split()[1]])
				# print line2 + " " + str(cnt)
				#f3.write(line2 + '\n')
				# line2.replace(line2.split()[1], "aaaa")
	f1.close()
	f2.close()
	f3.close()
dict = {}
def Match():
	f1 = open('machineLearningJanuary.txt',"r")
	f2 = open('finalResult.txt', "a")
	

	for line in f1:
		if line.strip():  #escape blank lines
			line = line.strip()
			if len(line.split())==6 and line.split()[1] != 'O':  # long entry
			#print line.strip()	
				dict[line.split()[2]] = line.split()[5]

				#for key, value in dict.items() :
					#print (key, value)

			# short entry
			elif re.match(r'^\d+\s\d+\s[a-zA-Z]+', line.strip()):
				#for 
				#new_line = dict[line.split()[0]]

				#pass
				 #new_line = line.replace(line.split()[0], dict[line.split()[0]])
				 #new_line = new_line.replace(line.split()[1], dict[line.split()[1]])
				# print new_line + "   "  + line.split()[0] + "    " + line.split()[1]
				# print new_line + " " + str(cnt)
				new_line = dict[line.split()[0]]+" " +dict[line.split()[1]]+" "+line.split()[2]

				f2.write(new_line + '\n')
			
	f1.close()
	f2.close()



if __name__ == '__main__':
	#Extract()
	Match()