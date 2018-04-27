import os, sys

entity_relations_file = open("entsAndRels.txt", 'r')
file_lines = entity_relations_file.readlines()

write_file = open('sendBackToBraydenWhenDone.txt','a')


for n in file_lines:
    print("Is the following statement true?(y or n, x to exit)")
    print(n)
    while True:
        input_var = raw_input()
        if input_var == 'y':
            write_file.write(n)
            break
        elif input_var == 'n':
            break
        elif input_var == 'x':
            sys.exit()
        else:
            input_var = ''
