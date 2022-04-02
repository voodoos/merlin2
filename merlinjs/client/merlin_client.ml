open Brr
module W = Brr_webworkers.Worker


let p_innerHTML = El.Prop.jstr (Jstr.of_string "innerHTML")
let text_input =
  Document.find_el_by_id G.document @@ Jstr.of_string "source-input"
  |> Option.get

let get_input_val () =
  El.(prop Prop.value text_input)

let results_div =
  Document.find_el_by_id G.document @@ Jstr.of_string "completion-results"
  |> Option.get

(* When a query is sent to the Worker we keep the Future result in an indexed
table so that the on_message function will be able to determine the Future when
the answer is posted by the Worker.
The Worker works synchronously so we expect answer to arrive in order. *)
let queue : (string -> unit) Queue.t = Queue.create ()
let add_fut res = Queue.add res queue
let res_fut v = (Queue.take queue) v
let worker = W.create @@ Jstr.of_string "merlin_worker.bc.js"
let query ((*todo: other queries*)) =
  let open Fut.Syntax in
  let fut, set  = Fut.create () in
  add_fut set;
  W.post worker (get_input_val () |> Jstr.to_string);
  let+ data = fut in
  Console.(log ["Received:"; data]);
  El.(set_prop p_innerHTML (Jstr.of_string data) results_div)

  let l : (string -> unit) -> string list -> unit = List.iter


let on_message m =
  let m = Ev.as_type m in
  let data : string list = Brr_io.Message.Ev.data m in
  let completions = String.concat "<br>" data in
  res_fut completions

let () = Ev.listen Brr_io.Message.Ev.message on_message @@ W.as_target worker

let on_input _e =
  Console.(log [get_input_val ()]);
  ignore (query ())

let () = Ev.(listen keyup on_input @@ El.as_target text_input)
