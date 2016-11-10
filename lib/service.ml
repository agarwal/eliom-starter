(** Service definitions. *)
open Eliom_parameter
include Eliom_service

let home = create ~path:(Path []) ~meth:(Get unit) ()

let github = extern ~prefix:"https://github.com"
    ~path:["agarwal"; "eliom-starter"]
    ~meth:(Get unit)
    ()

let jquery = extern ~prefix:"https://ajax.googleapis.com"
    ~path:["ajax"; "libs"; "jquery"; "2.2.4"; "jquery.min.js"]
    ~meth:(Get unit)
