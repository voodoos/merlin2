open Brr
module Worker = Brr_webworkers.Worker


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
type worker = {
  worker: Worker.t;
  queue: (Jv.t -> unit) Queue.t
}

let add_fut worker res = Queue.add res worker.queue
let res_fut worker v = (Queue.take worker.queue) v

let make_worker url =
  let worker = Worker.create @@ Jstr.of_string url in
  let queue = Queue.create () in
  let worker = { worker; queue } in
  let on_message m =
    let m = Ev.as_type m in
    let data = Brr_io.Message.Ev.data m in
    res_fut worker data
  in
  Ev.listen Brr_io.Message.Ev.message on_message @@
    Worker.as_target worker.worker;
  worker

let query worker source cursor_offset ((*todo: other queries*)) =
  let open Fut.Syntax in
  let fut, set  = Fut.create () in
  add_fut worker set;
  Worker.post worker.worker (source, cursor_offset);
  let+ data : Jv.t = fut in
  Console.(log ["Received:"; data]);
  (* El.(set_prop p_innerHTML (Jstr.of_string data) results_div); *)
  Ok data

  let l : (string -> unit) -> string list -> unit = List.iter

(* let on_input _e =
  Console.(log [get_input_val ()]);
  ignore (query worker ())

let () = Ev.(listen keyup on_input @@ El.as_target text_input) *)
let make_worker () = make_worker "merlin_worker.bc.js"
let () = Jv.set Jv.global "make_worker" (Jv.repr make_worker)

(* let res_to_jv = function
  | Completions l -> Jv.of_list (fun {name; kind; typ} ->
    Console.(log ["Name:"; name]);
      Jv.obj [|("name", Jv.repr name);
        ("kind", Jv.repr kind);
        ("typ", Jv.repr typ)|]) l *)

let query worker source cursor_offset =
  let source = Jv.to_string source in
  Fut.to_promise ~ok:Fun.id (query worker source cursor_offset ())

let () = Jv.set Jv.global "query_worker" (Jv.repr query)
