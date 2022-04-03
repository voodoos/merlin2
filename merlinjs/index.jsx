import { EditorState, EditorView, basicSetup } from "@codemirror/basic-setup"
import { autocompletion, CompletionContext } from "@codemirror/autocomplete"
import { StreamLanguage } from "@codemirror/stream-parser"
import { oCaml } from "@codemirror/legacy-modes/mode/mllike"

/* I was not able to have the client behave as a module so it needs to be loaded
before-hand in the browser */
let merlin_worker = make_worker()

/**
 * @param {CompletionContext} context
 */
function merlin_prefix_completion(context /*: CompletionContext */) {
  let fulltext = context.state.doc.toJSON().join(context.state.lineBreak)
  let result = query_worker(merlin_worker, fulltext, context.pos)
  return result.then(res => {
    let options = res.entries.map(entry => ({
      label: entry.name,
      detail: entry.desc
    }))
    return {
      from: res.from,
      to: res.to,
      options,
      filter: true
    }
  })
}

let ocaml = StreamLanguage.define(oCaml)

new EditorView({
  state: EditorState.create({ extensions: [basicSetup, ocaml,  autocompletion({override: [merlin_prefix_completion]})] }),
  parent: document.getElementById('editor')
})
