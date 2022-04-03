import { EditorState, EditorView, basicSetup } from "@codemirror/basic-setup"
import { autocompletion, CompletionContext } from "@codemirror/autocomplete"
import { StreamLanguage } from "@codemirror/stream-parser"
import { oCaml } from "@codemirror/legacy-modes/mode/mllike"

/* I was not able to have the client behave as a module so it needs to be loaded
before hand in the browser */
let merlin_worker = make_worker()

// let res_promise = query_worker(merlin_worker, "S")
// console.log (res_promise)

/**
 * @param {CompletionContext} context
 */
function merlin_prefix_completion(context /*: CompletionContext */) {
  let fulltext = context.state.doc.toJSON().join(context.state.lineBreak)
  let result = query_worker(merlin_worker, fulltext, context.pos)
  return result.then(res => {
    let options = res.entries.map(entry => { return {
      label: entry.name,
      detail: entry.desc
    }})
    let completion = {
      from: res.from,
      to: res.to,
      options: options,
      filter: false
    }
    console.log(completion)
    return completion
  })
  // let word = context.matchBefore(/\w*/)
  // if (word.from == word.to && !context.explicit)
  //   return null
  // else {
  //   return {
  //     from: word.from,
  //     options: []

  //     // [
  //     //   {label: "match", type: "keyword"},
  //     //   {label: "hello", type: "variable", info: "(World)"},
  //     //   {label: "magic", type: "text", apply: "⠁⭒*.✩.*⭒⠁", detail: "macro"}
  //     // ]
  //   }
  //}
}

// let state = EditorState.create({
//   doc: "Press Ctrl-Space in here...\n",
//   extensions: [basicSetup, autocompletion({override: [myCompletions]})]
// })

let ocaml = StreamLanguage.define(oCaml)

let view = new EditorView({
  state: EditorState.create({ extensions: [basicSetup, ocaml,  autocompletion({override: [merlin_prefix_completion]})] }),
  parent: document.getElementById('editor')
})
