open Lwt
open Eliom_registration

let () = Html.register ~service:Service.home Content.front_page
let () = Html.register ~service:Service.button Content.button_page
