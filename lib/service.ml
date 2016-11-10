(** Service definitions. *)
open Eliom_parameter
include Eliom_service

let home = create ~path:(Path []) ~meth:(Get unit) ()
let users = create ~path:(Path ["users"]) ~meth:(Get unit) ()

let add_user = create ~path:No_path
    ~meth:(Post (unit, string "username" ** string "password"))
    ()

let github = extern ~prefix:"https://github.com"
    ~path:["agarwal"; "eliom-starter"]
    ~meth:(Get unit)
    ()

let jquery = extern ~prefix:"https://ajax.googleapis.com"
    ~path:["ajax"; "libs"; "jquery"; "2.2.4"; "jquery.min.js"]
    ~meth:(Get unit)
    ()
