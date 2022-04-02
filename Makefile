all: build ocamlmerlin ocamlmerlin-server dot-merlin-reader

build:
	dune build --always-show-command-line

ocamlmerlin ocamlmerlin-server dot-merlin-reader:
	ln -s _build/install/default/bin/$@ ./$@

clean:
	dune clean

test: build
	dune runtest

preprocess:
	dune build --always-show-command-line @preprocess

promote:
	dune promote

js:
	dune build --watch --profile=release ./merlinjs/merlin_worker.bc.js ./merlinjs/client/merlin_client.bc.js

.PHONY: all js build dev clean test promote
