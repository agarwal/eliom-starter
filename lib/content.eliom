[%%shared
open Lwt
open Eliom_content
]

(* For dev usage. Quickly create a dummy link with given text. *)
let a_dummy x = Html.F.(a ~service:Service.home [pcdata x] ())

let jquery_src =
  "https://ajax.googleapis.com/ajax/libs/jquery/2.2.4/jquery.min.js"

(******************************************************************************)
(** {2 Template}*)
(******************************************************************************)
let template ~title:title_str content =
  let open Html.F in
  let head =
    head
      (title @@ pcdata title_str)
      [
        meta () ~a:[a_charset "utf-8"];
        meta () ~a:[
          a_http_equiv "x-ua-compatible";
          a_content "ie=edge";
        ];
        meta () ~a:[
          a_name "viewport";
          a_content "width=device-width,initial-scale=1.0";
        ];
        link () ~rel:[`Stylesheet]
          ~href:(Xml.uri_of_string "/css/app.css");
        link () ~rel:[`Stylesheet]
          ~href:(Xml.uri_of_string "/css/foundation-icons.css");
      ]
  in
  let top_bar_left =
    div ~a:[a_class ["top-bar-left"]] [
      ul ~a:[a_class ["menu"]] [
        li [a ~service:Service.home [i ~a:[a_class ["fi-home"]] []] ()];
      ]
    ]
  in
  let top_bar_right =
    div ~a:[a_class ["top-bar-right"]] [
      ul ~a:[a_class ["menu"]] [
        li [a ~service:Service.button [pcdata "Button"] ()];
      ]
    ]
  in
  let top_bar =
    div ~a:[a_class ["top-bar"]] [top_bar_left; top_bar_right]
  in
  let footer =
    footer [
      div ~a:[a_class ["row"]] [
        div ~a:[a_class ["small-8"; "columns"]] [
          pcdata "License: ISC";
        ];
        div ~a:[a_class ["small-4"; "columns"; "text-right"]] [
          a ~service:Service.github [i ~a:[a_class ["fi-social-github"]] []] ()
        ]
      ]
    ]
  in
  let end_matter =
    [
      js_script ~uri:(Xml.uri_of_string jquery_src) ();
      js_script ~uri:(Xml.uri_of_string "/js/app-deps.min.js") ();
      Raw.script (pcdata "$(document).foundation();");
    ]
  in
  html
    head
    (body @@ [top_bar]@content@[footer]@end_matter)

(******************************************************************************)
(** {2 Pages}*)
(******************************************************************************)
let front_page () () =
  let content =
    Html.F.(
      div ~a:[a_class ["row"]] [
        div ~a:[a_class ["small-12"; "columns"]] [
          h2 [pcdata (Printf.sprintf "X = %d" B.b)]
        ]
      ]
    )
  in
  return @@ template ~title:"Front Page" [content]

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
    button
      ~a:[
        a_onclick onclick_handler;
        Unsafe.string_attrib "type" "submit";
        a_class ["button"];
      ]
      [pcdata "Read value"]
  in
  let content =
    [
      div ~a:[a_class ["row"]] [
        div ~a:[a_class ["small-12"; "columns"]] [
          h1 [pcdata "Button"];
        ]
      ];

      div ~a:[a_class ["row"]] [
        div ~a:[a_class ["small-6"; "columns"]] [
          form [input; button]
        ]
      ];
    ]
  in
  return @@ template ~title:"Button" content
