open Lwt

let () = App.register ~service:Service.home Content.front_page

let () =
  Eliom_registration.Action.register
    ~service:Service.add_user
    (fun () (username,password) ->
       User.add_user username password
    )

let () = App.register ~service:Service.users Content.users
