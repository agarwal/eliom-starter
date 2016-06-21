OCAMLBUILD=ocamlbuild -verbose 1 -use-ocamlfind -plugin-tags "package(solvuu_build)"

default: client server-byte

all: default server-native

run-site: client server-byte
	mkdir -p _build/var/data _build/var/log
	ocsigenserver -c config.xml

client: _build/static/mysite.js
server-byte: _build/_server/mysite.cma
server-native: _build/_server/mysite.cmxa

_build/static/mysite.js: _build/_client/mysite.js
	mkdir -p _build/static
	cp -f $< $@

_build/_client/mysite.cma:
	$(OCAMLBUILD) _client/mysite.cma

_build/_client/mysite.js:
	$(OCAMLBUILD) _client/mysite.js

_build/_server/mysite.cma:
	$(OCAMLBUILD) _server/mysite.cma 

_build/_server/mysite.cmxa:
	$(OCAMLBUILD) _server/mysite.cmxa 

clean:
	ocamlbuild -clean

.PHONY: default all clean client server-byte server-native run-site
