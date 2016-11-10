open Lwt

let () = App.register ~service:Service.home Content.front_page
