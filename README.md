This is a temporary project to test out a new build system for Eliom
projects. The goal is to avoid all of the eliom command line tools,
which are just wrappers around underling ocaml tools.

The main work of this repo is in `myocamlbuild.ml`. It makes use of
`solvuu_build`, which will need to be installed by doing:

    opam pin add solvuu_build https://github.com/solvuu/solvuu_build.git

Then, you can try `make run-site`. This should compile and run the
ocsigen site at [http://localhost:8082](http://localhost:8082).
