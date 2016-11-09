open Printf
open Solvuu_build.Std

let project_name = "eliom-starter"
let version = "dev"

let annot = Some ()
let bin_annot = Some ()
let g = Some ()
let safe_string = Some ()
let short_paths = Some ()
let thread = Some ()
let w = Some "A-4-33-41-42-44-45-48"
let dir = "lib"

let ml_files = function
  | `Server ->
    [
      "a.ml";"b.ml";"app.eliom";
      "content.eliom";
      "registration.ml";
      "service.ml";
    ]
  | `Client ->
    [
      "app.eliom";
      "content.eliom";
    ]

let mli_files = function
  | `Server ->
    ["b.mli"]
  | `Client ->
    []

let findlib_deps = function
  | `Server ->
    [
      "eliom.server"; "eliom.ppx.server";
      "js_of_ocaml.deriving.ppx"; "js_of_ocaml.ppx";
    ]
  | `Client ->
    [
      "eliom.client"; "eliom.ppx.client";
      "js_of_ocaml.ppx";
    ]

let lib =
  Eliom.lib project_name
    ~style:(`Pack (String.map (function '-' -> '_' | c -> c) project_name))
    ~dir
    ~findlib_deps
    ~ml_files
    ~mli_files
    ?annot
    ?bin_annot
    ?g
    ?safe_string
    ?short_paths
    ?thread
    ?w

;;
let () = Ocamlbuild_plugin.dispatch @@ function
| Ocamlbuild_plugin.After_rules -> (
    Ocamlbuild_plugin.clear_rules();
    Eliom.build_lib lib;
  )
| _ -> ()
