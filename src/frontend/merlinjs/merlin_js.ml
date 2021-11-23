
let verbosity pipeline =
  Mconfig.((Mpipeline.final_config pipeline).query.verbosity)
in
let source = Msource.make ("let x = 3") in
let pipeline = Mpipeline.make Mconfig.initial source in

let typer = Mpipeline.typer_result pipeline in
let verbosity = verbosity pipeline in
let pos = `Start in
let pos = Mpipeline.get_lexing_pos pipeline pos in
let structures = Mbrowse.enclosing pos
  [Mbrowse.of_typedtree (Mtyper.get_typedtree typer)] in
let path = match structures with
  | [] -> []
  | browse -> Browse_misc.annotate_tail_calls browse
in

let _result = Type_enclosing.from_nodes ~path in
()
