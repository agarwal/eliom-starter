[%%shared
    open Printf
    open Eliom_lib
]

module Mysite =
  Eliom_registration.App (
  struct
    let application_name = "mysite"
  end)

let _ = Mysite.register_service
    ~path:[]
    ~get_params:Eliom_parameter.unit
    (fun () () ->
       Lwt.return
         (Eliom_tools.F.html
            ~title:"mysite"
            Eliom_content.Html5.F.(body [
              h2 [pcdata (sprintf "X = %d" B.b)];
            ] )
         )
    )

let _ = Mysite.register_service
    ~path:["a"]
    ~get_params:Eliom_parameter.unit
    (fun () () ->
       let open Eliom_content.Html5.D in
       let input = input ~a:[a_input_type `Text] () in
       let onclick_handler = [%client (fun _ ->
            let v =
              Js.to_string
                (Eliom_content.Html5.To_dom.of_input ~%input)##.value
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
