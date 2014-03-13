ifndef OCAMLC
	OCAMLC=ocamlc
endif
ifndef OCAMLOPT
	OCAMLOPT=ocamlopt
endif
ifndef CAMLP4O
	CAMLP4O=camlp4o
endif

export OCAMLC
export OCAMLOPT
export CAMLP4O

CAMLP4=-pp $(CAMLP4O)
COMMONCAMLFLAGS=-I /usr/lib/ocaml/cryptokit
OCAMLDEP=ocamldep $(CAMLP4)
CAMLLIBS=unix.cma str.cma nums.cma bigarray.cma cryptokit.cma
OCAMLFLAGS=$(COMMONCAMLFLAGS) $(CAMLLIBS)
OCAMLOPTFLAGS=$(COMMONCAMLFLAGS) $(CAMLLIBS:.cma=.cmxa)

ALLOBJS=pMap.cmx pSet.cmx utils.cmx settings.cmx common.cmx channel.cmx \
		packet.cmx parsePGP.cmx sStream.cmx key.cmx keyMerge.cmx fixkey.cmx \
		fingerprint.cmx

all: listall

listall: $(ALLOBJS) listall.cmx
	$(OCAMLOPT) -o listall $(OCAMLOPTFLAGS) $(ALLOBJS) listall.cmx

# Special case
keyMerge.cmo: keyMerge.ml
	$(OCAMLC) $(OCAMLFLAGS) $(CAMLP4) -c $<

keyMerge.cmx: keyMerge.ml
	$(OCAMLOPT) $(OCAMLOPTFLAGS) $(CAMLP4) -c $<

.SUFFIXES: .mli .ml .cmo .cmi .cmx

.ml.o:
	$(OCAMLOPT) -output-obj $(OCAMLOPTFLAGS) $<

.ml.cmo:
	$(OCAMLC) $(OCAMLFLAGS) -c $<

.mli.cmi:
	$(OCAMLC) $(OCAMLFLAGS) -c $<

.ml.cmx:
	$(OCAMLOPT) $(OCAMLOPTFLAGS) -c $<

clean:
	rm -f *.o
	rm -f *.cm[iox]
	rm -f *.annot
	rm -f .depend
	rm -f listall

dep:
	$(OCAMLDEP) $(INCLUDES) *.mli *.ml > .depend

-include .depend
