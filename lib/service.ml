(** Service definitions. *)
open Eliom_parameter
open Eliom_service

let home = create ~path:(Path []) ~meth:(Get unit) ()
let button = create ~path:(Path ["button"]) ~meth:(Get unit) ()

let github = extern ~prefix:"https://github.com"
    ~path:["agarwal"; "eliom-starter"]
    ~meth:(Get unit)
    ()
