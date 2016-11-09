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

let _ = Eliom_registration.Html.create
    ~path:(Eliom_service.Path [])
    ~meth:(Eliom_service.Get Eliom_parameter.unit)
    (fun () () ->
       let open Eliom_content.Html.F in
       Lwt.return
         (html
            (head (title @@ pcdata "mysite") [])
            (body [
               h2 [pcdata (sprintf "X = %d" B.b)];
             ]
            )
         )
    )

let _ = Eliom_registration.Html.create
    ~path:(Eliom_service.Path ["a"])
    ~meth:(Eliom_service.Get Eliom_parameter.unit)
    (fun () () ->
       let open Eliom_content.Html.D in
       let input = input ~a:[a_input_type `Text] () in
       let onclick_handler = [%client (fun _ ->
            let v =
              Js.to_string
                (Eliom_content.Html.To_dom.of_input ~%input)##.value
            in
            Dom_html.window##alert(Js.string ("Input value :" ^ v)))
       ]
       in
       let button =
         button ~a:[a_onclick onclick_handler] [pcdata "Read value"]
       in
       Lwt.return
         (html
            (head (title (pcdata "Test")) [])
            (body [input; button])
         )
    )
