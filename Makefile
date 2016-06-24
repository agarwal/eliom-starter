OCAMLBUILD=ocamlbuild -verbose 1 -use-ocamlfind -plugin-tags "package(solvuu_build)"

default: run-site
all: default server-native

################################################################################
# Client
client: _build/_client/mysite.js

_build/_client/mysite.js:
	$(OCAMLBUILD) _client/mysite.js

_build/_client/mysite.cma:
	$(OCAMLBUILD) _client/mysite.cma

################################################################################
# Server - byte code
server-byte: _build/_server/mysite.cma

_build/_server/mysite.cma:
	$(OCAMLBUILD) _server/mysite.cma 

################################################################################
# Server - native code
server-native: _build/_server/mysite.cmxa

_build/_server/mysite.cmxa:
	$(OCAMLBUILD) _server/mysite.cmxa 

################################################################################
# Site
run-site: client server-byte
	mkdir -p _site/var/data _site/var/log _site/static
	cp _build/_client/mysite.js _site/static/
	ocsigenserver -c config.xml

################################################################################
# Clean
clean:
	ocamlbuild -clean
	rm -rf _site

.PHONY: default all clean client server-byte server-native run-site
