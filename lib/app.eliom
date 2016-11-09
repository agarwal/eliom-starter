[%%shared
open Lwt
open Printf
open Eliom_lib
]

include Eliom_registration.App (
  struct
    let application_name = "app"
    let global_data_path = None
  end)
