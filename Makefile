eliomc=eliomc -ppx -thread -g -package eliom.server,eliom.ppx.server -I _server/lib
js_of_eliom=js_of_eliom -ppx -g -package eliom.client,eliom.ppx.client,js_of_ocaml.ppx -I _client/lib

default: client server-byte

server-byte:
	mkdir -p _build/_server/lib
	$(eliomc) -c -for-pack Mysite -o _server/lib/a.cmo lib/a.ml
	$(eliomc) -c -for-pack Mysite -o _server/lib/b.cmi lib/b.mli
	eliomc -infer -ppx -thread -g -package eliom.server,eliom.ppx.type -I _server/lib -o _server/lib/app.type_mli lib/app.eliom
	$(eliomc) -c -for-pack Mysite -o _server/lib/b.cmo lib/b.ml
	$(eliomc) -c -for-pack Mysite -o _server/lib/app.cmo lib/app.eliom
	$(eliomc) -pack -o _server/mysite.cmo _server/lib/a.cmo _server/lib/b.cmo _server/lib/app.cmo
	$(eliomc) -a -linkall -o _server/mysite.cma _server/mysite.cmo

client: server-byte
	mkdir -p _build/_client/lib
	$(js_of_eliom) -c -for-pack Mysite -o _client/lib/app.cmo lib/app.eliom
	$(js_of_eliom) -pack -o _client/mysite.cmo _client/lib/app.cmo
	$(js_of_eliom) -a -linkall -o _client/mysite.cma _client/mysite.cmo
	$(js_of_eliom) -linkall -o _client/mysite.js _client/mysite.cma

run-site: client server-byte
	mkdir -p _var/log _var/data
	ocsigenserver -c config.xml

clean:
	rm -rf _var _server _client lib/*.cm* lib/*.annot

.PHONY: clean client server-byte server-native run-site
