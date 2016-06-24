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
      ["app.eliom"] |>
      List.map ~f:(fun x -> "lib"/x)
    )

let packages = function
  | `Server -> ["eliom.server"]
  | `Client -> ["eliom.client"; "js_of_ocaml.ppx"]

let outdir = function
  | `Server -> "_server"
  | `Client -> "_client"

let mkdir dir =
  let cmd = sprintf "mkdir -p %s" dir in
  match Sys.command cmd with
  | 0 -> ()
  | x -> failwithf "%s: returned with exit code %d" cmd x ()

let build_lib host : unit =
  let files = files host in
  let package = packages host in
  let outdir_server = outdir `Server in (* needed even for `Client *)
  let outdir = outdir host in
  let for_pack = String.capitalize project_name in
  let pathI = [outdir/"lib"] in
  mkdir ("_build"/outdir/"lib");

  (* let ocamlc = ocamlfind_ocamlc *)
  (*     ?annot ?bin_annot ?g ?safe_string ?short_paths ?thread ?w *)
  (*     ~package ~pathI *)
  (* in *)

  let compile ?c ?a ?o ?for_pack ?pack ?linkall files =
    match host with
    | `Server ->
      Tools.eliomc ?c ?a ?o ?for_pack ?pack ?linkall files
        ?annot ?bin_annot ?g ?safe_string ?short_paths ?thread ?w
        ~package ~pathI ~ppx:()
    | `Client ->
      Tools.js_of_eliom ?c ?a ?o ?for_pack ?pack ?linkall:None ?linkall files
        ?annot ?bin_annot ?g ?safe_string ?short_paths ?thread ?w
        ~package ~pathI ~ppx:()
  in

  let run_ocamldep = Tools.run_ocamlfind_ocamldep
      ~ml_synonym:".eliom"
      ~mli_synonym:".eliomi"
      ~package ~pathI:["lib"]
  in

  let run_ocamldep_sort = Tools.run_ocamlfind_ocamldep_sort
      ~ml_synonym:".eliom"
      ~mli_synonym:".eliomi"
      ~package ~pathI:["lib"]
  in

  (* Return main target resulting from compiling given file [x]. *)
  let target x =
    let base = chop_extension x in
    if check_suffix x ".mli" || check_suffix x ".eliomi" then base^".cmi"
    else if check_suffix x ".ml" || check_suffix x ".eliom" then base^".cmo"
    else failwithf "don't know target of %s" x ()
  in

  (* Assure source files all have been copied. *)
  let assert_source_files build =
    List.map files ~f:(fun x -> [x]) |>
    build |> assert_all_outcomes |> ignore
  in

  (* Discover and build dependencies of given file [x]. *)
  let build_deps build x =
    assert_source_files build;
    let y = target x in
    run_ocamldep [x] |> fun l ->
    match List.Assoc.find l y with
    | None ->
      failwithf "ocamldep on %s gave no results for %s" x y ()
    | Some l ->
      let set = List.map files ~f:chop_extension in
      List.filter l ~f:(fun x -> List.mem ~set (chop_extension x)) |>
      List.map ~f:(fun x -> outdir/x) |> fun l ->
      printf "dependencies of %s: %s\n" (outdir/y) (String.concat ~sep:"," l);
      List.map l ~f:(fun x -> [x]) |>
      build |> assert_all_outcomes |> ignore
  in

  (* Generate .type_mli files. *)
  (match host with
   | `Client -> ()
   | `Server ->
     List.filter files ~f:(fun x -> check_suffix x ".eliom") |>
     List.iter ~f:(fun eliom ->
       let base = chop_extension eliom in
       let prod = outdir/(base^".type_mli") in
       Rule.rule ~deps:[eliom] ~prods:[prod] (fun _ build ->
         build_deps build eliom;

         Tools.eliomc ~infer:() ~o:prod [eliom]
           ~package:["eliom.ppx.type"]
           ?annot ?bin_annot ?g ?safe_string ?short_paths ?thread ?w
           ~pathI ~ppx:()
       )
     )
  );

  (* Compile .mli/.eliomi/.ml/.eliom files. *)
  List.iter files ~f:(fun x ->
    let base = chop_extension x in
    if check_suffix x ".mli" then (
      let mli = x in
      let cmi = outdir/(base^".cmi") in
      Rule.rule ~deps:[mli] ~prods:[cmi] (fun _ build ->
        build_deps build mli;
        compile ~c:() ~o:cmi ~for_pack [mli]
      )
    )
    else if check_suffix x ".eliomi" then (
      let eliomi = x in
      let cmi = outdir/(base^".cmi") in
      Rule.rule ~deps:[eliomi] ~prods:[cmi] (fun _ build ->
        build_deps build eliomi;
        compile ~c:() ~o:cmi ~for_pack [eliomi]
      )
    )
    else if check_suffix x ".ml" then (
      let ml = x in
      let cmo = outdir/(base^".cmo") in
      Rule.rule ~deps:[ml] ~prods:[cmo] (fun _ build ->
        build_deps build ml;
        compile ~c:() ~o:cmo ~for_pack [ml]
      )
    )
    else if check_suffix x ".eliom" then (
      let eliom = x in
      let cmo = outdir/(base^".cmo") in
      let type_mli = outdir_server/(base ^ ".type_mli") in
      Rule.rule ~deps:[eliom;type_mli] ~prods:[cmo] (fun _ build ->
        build_deps build eliom;
        (* let ppxopt = *)
        (*   let opt = sprintf "-type %s" type_mli in *)
        (*   match host with *)
        (*   | `Client -> ["eliom.ppx.client",opt] *)
        (*   | `Server -> ["eliom.ppx.server",opt] *)
        (* in *)
        compile ~c:() ~o:cmo ~for_pack [eliom]
      )
    )
    else
      failwithf "don't know how to compile %s" x ()
  );

  (* Pack cmo files to a single cmo. *)
  (
    let prod = outdir/(project_name^".cmo") in
    Rule.rule ~deps:files ~prods:[prod] (fun _ build ->
      let cmos =
        List.filter files ~f:(
          fun x -> check_suffix x ".ml" || check_suffix x ".eliom"
        ) |>
        run_ocamldep_sort |>
        List.filter ~f:(List.mem ~set:files) |>
        List.map ~f:(fun x -> outdir/((chop_extension x)^".cmo"))
      in
      printf "sorted dependencies of %s: %s\n"
        prod (String.concat ~sep:"," cmos)
      ;
      (
        List.map cmos ~f:(fun x -> [x]) |>
        build |> assert_all_outcomes |> ignore
      );
      compile ~pack:() ~o:prod cmos
    )
  );

  (* Packed .cmo -> .cma. *)
  (
    let base = outdir/project_name in
    let cmo = base^".cmo" in
    let cma = base^".cma" in
    Rule.rule ~deps:[cmo] ~prods:[cma] (fun _ _ ->
      compile ~a:() ~linkall:() ~o:cma [cmo]
    )
  );

  (* Compile javascript library. *)
  (match host with
   | `Server -> ()
   | `Client ->
     let base = outdir/project_name in
     let cma = base^".cma" in
     (* let byte = base^".byte" in *)
     let js = base^".js" in

     (* Rule.rule ~deps:[cma] ~prods:[byte] (fun _ _ -> compile ~o:byte [cma]); *)

     Rule.rule ~deps:[cma] ~prods:[js] (fun _ _ ->
       compile ~linkall:() ~o:js [cma]
     )
  );

;;

let () = Ocamlbuild_plugin.dispatch @@ function
| Ocamlbuild_plugin.After_rules -> (
    Ocamlbuild_plugin.clear_rules();
    List.iter [`Server; `Client] ~f:build_lib;
  )
| _ -> ()
