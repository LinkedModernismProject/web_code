OCAMLFIND=ocamlfind
CMO=cmo
CMA=cma
OCAMLC=$(OCAMLFIND) ocamlc
INCLUDES= -I lib -I lib/dcg -I lib/ipp  # all relevant -I options here
OCAMLFLAGS= -pp "camlp4o -I lib/dcg -I lib/ipp pa_dcg.cmo pa_ipp.cmo" -w usy -thread $(INCLUDES)    # add other options for ocamlc here

SQUALL_SRC = semantics.ml syntax.ml sparql.ml dbpedia.ml
SQUALL_OBJ = $(SQUALL_SRC:.ml=.$(CMO))

all: lib/dcg/dcg.cma lib/ipp/ipp.cma script interpreter

lib/dcg/dcg.cma:
	cd lib/dcg && make

lib/ipp/ipp.cma:
	cd lib/ipp && make

script: $(SQUALL_OBJ) squall2sparql.$(CMO)
	$(OCAMLC) $(INCLUDES) -g -custom -o squall2sparql str.$(CMA) dcg.$(CMA) ipp.$(CMA) $(SQUALL_OBJ) squall2sparql.$(CMO)

interpreter: $(SQUALL_OBJ) main.$(CMO)
	$(OCAMLC) $(INCLUDES) -g -o squall.exe str.$(CMA) dcg.$(CMA) ipp.$(CMA) $(SQUALL_OBJ) main.$(CMO)

webform: webform.ml
	$(OCAMLC) $(INCLUDES) -thread -package eliom.server -c webform.ml
	$(OCAMLC) $(INCLUDES) -a -o webform.cma dcg.$(CMA) ipp.$(CMA) $(SQUALL_OBJ) webform.$(CMO)

# Common rules
.SUFFIXES: .mll .ml .mli .$(CMO) .cmi

%.$(CMO): %.ml
	$(OCAMLC) $(OCAMLFLAGS) -c $<

# Clean up
clean:
	rm -f *.cm[ioax]
	rm -f *.o

cleanall: clean
	cd lib/dcg && make clean
	cd lib/ipp && make clean

lisfs2008:
	install -o ocsigen -g ocsigen -m 644 webform.cma /var/lib/ocsigenserver/
	install -o ocsigen -g ocsigen -m 644 webform.css /var/lib/ocsigenserver/static/
	install -o ocsigen -g ocsigen -m 644 images/* /var/lib/ocsigenserver/static/images/

