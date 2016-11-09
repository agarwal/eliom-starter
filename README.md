# eliom-starter

The goal of this project is to help beginners implement a website
using [Eliom](http://ocsigen.org/eliom/), a project of the
[Ocsigen](http://ocsigen.org/) suite. We strive to strike a balance
between keeping it simple and demonstrating features needed to build a
real website. For example, a real website needs to incorporate CSS and
3rd party JavaScript libraries, so we do so here even if technically
this is orthogonal to learning Eliom.

## Quickstart

Install dependencies by doing:

```sh
opam pin add -n js_of_ocaml.dev https://github.com/ocsigen/js_of_ocaml.git
opam pin add -n ocsigenserver.dev https://github.com/ocsigen/ocsigenserver.git
opam pin add -n eliom.dev https://github.com/ocsigen/eliom.git
opam install eliom solvuu-build
```

Now you can compile this project by running `make`, which also
launches the website at
[http://localhost:8082](http://localhost:8082).

## Build System

The entry point to the build system is the `Makefile`, which supports
the following:

- Compilation of OCaml code: The main code implementing the website is
  under `lib/`. [Building an `eliom`
  project](http://ocsigen.org/eliom/5.0/manual/workflow-compilation)
  is different than compiling a normal OCaml project. This is because
  your source code is compiled twice, once for the server side (to an
  OCaml library) and once for the client side (to JavaScript). The
  `Makefile` delegates this work to
  [solvuu-build](https://github.com/solvuu/solvuu-build/blob/master/lib/solvuu_build_eliom.mli). The
  only thing we have to do here is provide a `myocamlbuild.ml` file to
  tell `solvuu-build` which files and findlib packages are needed for
  the client and server sides.

- CSS: Zurb's [Foundation for Sites](http://foundation.zurb.com/sites)
  is installed by a call to `npm`, which installs the package in the
  `node_modules` directory. The `static/css` directory contains Sass
  `.scss` design files, which you can customize. These are compiled to
  `.css` using `node-sass`.

- JavaScript: Foundation also includes JavaScript files, and you might
  want to use other 3rd party JavaScript libraries. In addition, your
  OCaml source code will be compiled to JavaScript. We use `babel` to
  transpile all of this into a single `.js` file. We do this for
  simplicity so that only a single `.js` file needs to be referenced
  in the generated HTML pages. In a real website, you may want load
  common JavaScript libraries from a CDN or consider other factors.

- Static Content: The above CSS and JavaScript files need to be served
  as static content, and your website might include other static files
  such as images. These all get put into `_build/_site`, which is the
  directory declared to be the static dir in `config.xml`.

- config.xml: This is the configuration file required by the Ocsigen
  server upon startup. We've set all directory paths to be relative,
  so everything stays under this project's root dir. A `make
  distclean` thus assures you wipe everything done by running this
  project. This file also specifies the port to serve the website
  from.

- Clean: Most build artifacts go under `_build`. Doing a `make clean`
  deletes this directory. However, the Makefile also downloads
  packages from the internet, and it would be wasteful to redo this
  too often. Downloads are put in `_cache`, and `npm` installs
  packages under `node_modules`. A `make clean` does *not* remove
  these directories. You must do `make clean-cache` to re-install 3rd
  party packages. Finally, running the website writes log files and
  updates a SQLite database file. The `config.xml` file sets paths for
  these to be under `_var`. This directory is deleted only upon a
  `make distclean`.
