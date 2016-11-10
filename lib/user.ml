(** User accounts. *)
open Lwt

let users : (string * string) list ref = ref []

let add_user username password =
  users := (username,password)::!users;
  return ()

let all_users () = return !users
