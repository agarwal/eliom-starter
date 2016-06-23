This is a temporary project to experiment with a new build script for Eliom. The project can be compiled in two ways:

* Do `make run-site`. The Makefile has hand written rules, so we can
  easily see the affect of small changes. However, this file doesn't
  scale to larger projects, e.g. there is no call to `eliomdep` to
  automatically figure out the order in which to compile different
  modules.

* Do `make -f Makefile.ocamlbuild run-site`. This will make use the
  `myocamlbuild.ml` plugin. This makes use of `solvuu_build`, which
  will need to be installed by doing:

      opam pin add solvuu_build https://github.com/solvuu/solvuu_build.git

In both cases, the site should be running at
[http://localhost:8082](http://localhost:8082).
