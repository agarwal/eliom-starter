open Printf
open Solvuu_build.Std
open Solvuu_build.Util
open Solvuu_build.Util.Filename
let (/) = Filename.concat

let project_name = "mysite"
let version = "dev"

let annot = Some ()
let bin_annot = Some ()
let g = Some ()
let safe_string = Some ()
let short_paths = Some ()
let thread = Some ()
let w = Some "A-4-33-41-42-44-45-48"

let files = function
  | `Server -> (
      ["a.ml";"b.ml";"b.mli";"app.eliom"] |>
      List.map ~f:(fun x -> "lib"/x)
    )
  | `Client -> (
      ["a.ml";"b.ml";"b.mli";"app.eliom"] |>
      List.map ~f:(fun x -> "lib"/x)
    )

let packages = function
  | `Server -> ["eliom.server"; "eliom.ppx.server"]
  | `Client -> ["eliom.client"; "eliom.ppx.client"]

let outdir = function
  | `Server -> "_server"
  | `Client -> "_client"

let lib host : Project.item = match host with
  | `Server ->
    Project.lib project_name
      ?annot ?bin_annot ?g ?safe_string ?short_paths ?thread ?w
      ~findlib_deps:(packages host)
      ~pkg:(sprintf "%s.server" project_name)
      ~pack_name:project_name
      ~dir:((outdir host)/"lib")
      ~mli_files:(`Replace ["b.mli"])
      ~ml_files:(`Replace ["a.ml";"b.ml";"app.ml"])
  | `Client ->
    Project.lib project_name
      ?annot ?bin_annot ?g ?safe_string ?short_paths ?thread ?w
      ~findlib_deps:(packages host)
      ~pkg:(sprintf "%s.client" project_name)
      ~pack_name:project_name
      ~dir:((outdir host)/"lib")
      ~mli_files:(`Replace ["b.mli"])
      ~ml_files:(`Replace ["a.ml";"b.ml";"app.ml"])

let build_lib host : unit =
  let lib = match lib host with
    | Project.Lib x -> x
    | Project.App _ -> assert false
  in

  Solvuu_build.Std.Project.build_lib lib;

  let file_base_of_module : string -> string option =
    Project.file_base_of_module lib
  in

  let ocamlc ?c ?dsource ?impl files =
    OCaml.ocamlfind_ocamlc files ?c ?dsource ?impl
      ?annot ?bin_annot ?g ?safe_string ?short_paths ?thread ?w
      ~pathI:[lib.Project.dir]
      ~package:lib.Project.findlib_deps
  in

  List.iter (files host) ~f:(fun x ->
    if check_suffix x ".ml" || check_suffix x ".mli" then (
      let y = (outdir host)/x in
      Rule.rule ~deps:[x] ~prods:[y] (fun _ _ ->
        Ocamlbuild_pack.Shell.mkdir_p (dirname y);
        Ocamlbuild_plugin.(Cmd (S [A"cp"; A"-f"; P x; P y]))
      )
    )
    else if check_suffix x ".eliom" then (
      let base = chop_extension x in
      let y = (outdir host)/(base^".ml") in
      Rule.rule ~deps:[x] ~prods:[y] (fun _ build ->
        let () =
          OCaml.run_ocamldep1 x
            ~modules:() ~ml_synonym:".eliom"
          |> List.filter_map ~f:file_base_of_module
          |> List.map ~f:(fun x -> [sprintf "%s.cmi" x])
          |> build
          |> assert_all_outcomes
          |> ignore
        in
        ocamlc ~c:() ~dsource:() ~impl:x [] |>
        Spec.spec_of_command |> fun cmd ->
        Ocamlbuild_plugin.(Cmd (S [cmd; Sh "2>|"; P y]))
      )
    )
  );

  (match host with
   | `Server -> ()
   | `Client ->
     let dep = Project.path_of_lib lib ~suffix:".cma" in
     let prod = Project.path_of_lib lib ~suffix:".js" in
     Rule.rule ~deps:[dep] ~prods:[prod] (fun _ _ ->
       OCaml.js_of_ocaml ~o:prod [] dep
     )
  )
;;

let () = Ocamlbuild_plugin.dispatch @@ function
| Ocamlbuild_plugin.After_rules -> (
    Ocamlbuild_plugin.clear_rules();
    List.iter [`Server; `Client] ~f:build_lib;
  )
| _ -> ()
