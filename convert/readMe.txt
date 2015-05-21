The Workbook2 file is the one that has the comma's(,) taken out for the pattern **********

#Going to try and work on converting N-Triples into Turtle format on mass scale.

convertCSVtoRDF_dust_test.py
	python convertCSVtoRDF_dust_test.py > out.nt
		cmd above was used to create a file of triples that I can parse through to get into Turtle format
			also gets rid of unallowed spaces in subject and predicate

test_parser.py
	python test_parser.py
	This now takes the out.nt from the conversion above and will parse through it to convert to Turtle, removes any unallowed char's from predicates


