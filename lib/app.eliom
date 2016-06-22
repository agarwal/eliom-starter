[%%shared
    open Printf
    open Eliom_lib
    open Eliom_content
    open Html5.D
]

module Mysite_app =
  Eliom_registration.App (
  struct
      let application_name = "mysite"
  end)

let main_service =
  Eliom_service.App.service ~path:[] ~get_params:Eliom_parameter.unit ()

let () = Mysite_app.register
    ~service:main_service
    (fun () () ->
       Lwt.return
         (Eliom_tools.F.html
            ~title:"mysite"
            Html5.F.(body [
              h2 [pcdata (sprintf "X = %d" B.b)];
            ] )
         )
    )
