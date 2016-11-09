[%%shared
open Lwt
open Eliom_content
]

let front_page () () =
  return Html.F.(
    html
      (head (title @@ pcdata "mysite") [])
      (body [
         h2 [pcdata (Printf.sprintf "X = %d" B.b)];
       ]
      )
  )

let button_page () () =
  let open Eliom_content.Html.D in
  let input = input ~a:[a_input_type `Text] () in
  let onclick_handler = [%client (fun _ ->
    let v =
      Js.to_string
        (Html.To_dom.of_input ~%input)##.value
    in
    Dom_html.window##alert(Js.string ("Input value :" ^ v)))
  ]
  in
  let button =
    button ~a:[a_onclick onclick_handler] [pcdata "Read value"]
  in
  return
    (html
       (head (title (pcdata "Test")) [])
       (body [input; button])
    )
