OCAMLBUILD=ocamlbuild -verbose 1 -use-ocamlfind -plugin-tags "package(solvuu-build)"

PROJECT_NAME=eliom-starter
APP_NAME=app

.PHONY: default
default: run-site

# Any target not handled by Makefile is passed onto ocamlbuild.
FORCE:
_build/%: FORCE
	$(OCAMLBUILD) $(patsubst _build/%, %, $@)

# Paths to local executables.
babel=node_modules/.bin/babel
node-sass=node_modules/.bin/node-sass

################################################################################
# Build & Run Website
.PHONY: site
site: \
  _build/_site/css/foundation-icons.css \
  _build/_site/css/$(APP_NAME).css \
  _build/_site/js/app-deps.min.js \
  _build/_site/$(APP_NAME).js \
  _build/_server/$(PROJECT_NAME).cma

.PHONY: run-site
run-site: site | _var/log _var/data
	ocsigenserver -c config.xml

################################################################################
# CSS
$(patsubst %, _build/_site/css/foundation-icons.%, css eot svg ttf woff) _build/_site/css/svgs: _cache/foundation-icons | _build/_site
	rsync -a --exclude=preview.html _cache/foundation-icons/ _build/_site/css

_build/_site/css/$(APP_NAME).css: \
  $(wildcard static/css/*.scss) \
  node_modules/foundation-sites \
  node_modules/node-sass \
  | _build/_site/css
	$(node-sass) \
          --include-path node_modules/foundation-sites/scss \
          static/css/$(APP_NAME).scss \
          >| $@


################################################################################
# JavaScript
_build/_site/js/app-deps.min.js: \
  node_modules/babel-cli \
  node_modules/foundation-sites \
  | _build/_site/js
	$(babel) -o $@ --minified \
          node_modules/foundation-sites/dist/foundation.js

_build/_site/$(APP_NAME).js: _build/_client/$(PROJECT_NAME).js | _build/_site
	cp -f $< $@


################################################################################
# 3rd Party Packages
_cache/foundation-icons: | _cache
	wget -O _cache/foundation-icons.zip http://zurb.com/playground/uploads/upload/upload/288/foundation-icons.zip
	unzip -q -o -d _cache _cache/foundation-icons.zip
	rm -rf _cache/__MACOSX

node_modules/babel-cli:
	npm install babel-cli

node_modules/foundation-sites:
	npm install foundation-sites@6.2.3

node_modules/node-sass:
	npm install node-sass@3.8.0


################################################################################
# Empty directories, used as order-only prerequisites
_cache:
	mkdir $@

_build:
	mkdir $@

_build/_site: | _build
	mkdir $@

_build/_site/css: | _build/_site
	mkdir $@

_build/_site/img: | _build/_site
	mkdir $@

_build/_site/js: | _build/_site
	mkdir $@

_var:
	mkdir $@

_var/log: | _var
	mkdir $@

_var/data: | _var
	mkdir $@


################################################################################
# Clean
.PHONY: clean
clean:
	rm -rf _build
	rm -f npm-debug.log

.PHONY: clean-cache
clean-cache:
	rm -rf _cache
	rm -rf node_modules

.PHONY: distclean
distclean: clean clean-cache
	rm -rf _var
