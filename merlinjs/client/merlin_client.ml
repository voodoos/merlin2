open Brr
module W = Brr_webworkers.Worker
let text_input =
  Document.find_el_by_id G.document @@ Jstr.of_string "source-input"
  |> Option.get

let get_input_val () =
  El.(prop Prop.value text_input)

let results_div =
  Document.find_el_by_id G.document @@ Jstr.of_string "completion-results"
  |> Option.get


let worker = W.create @@ Jstr.of_string "merlin_worker.bc.js"

let p_innerHTML = El.Prop.jstr (Jstr.of_string "innerHTML")

let on_message m =
  let m = Ev.as_type m in
  let data : string list = Brr_io.Message.Ev.data m in
  let completions = String.concat "<br>" data in
  Console.(log ["Received:"; data]);
  El.(set_prop p_innerHTML (Jstr.of_string completions) results_div)

let () = Ev.listen Brr_io.Message.Ev.message on_message @@ W.as_target worker

let on_input _e =
  Console.(log [get_input_val ()]);
  W.post worker @@ get_input_val ()

let () = Ev.(listen keyup on_input @@ El.as_target text_input)
