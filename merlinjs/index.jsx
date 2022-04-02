import { EditorState, EditorView, basicSetup } from "@codemirror/basic-setup"
import { autocompletion, CompletionContext } from "@codemirror/autocomplete"
import { StreamLanguage } from "@codemirror/stream-parser"
import { oCaml } from "@codemirror/legacy-modes/mode/mllike"

/**
 * @param {CompletionContext} context
 */
function myCompletions(context /*: CompletionContext */) {
  let word = context.matchBefore(/\w*/)
  if (word.from == word.to && !context.explicit)
    return null
  return {
    from: word.from,
    options: [
      {label: "match", type: "keyword"},
      {label: "hello", type: "variable", info: "(World)"},
      {label: "magic", type: "text", apply: "⠁⭒*.✩.*⭒⠁", detail: "macro"}
    ]
  }
}

// let state = EditorState.create({
//   doc: "Press Ctrl-Space in here...\n",
//   extensions: [basicSetup, autocompletion({override: [myCompletions]})]
// })

let ocaml = StreamLanguage.define(oCaml)

let view = new EditorView({
  state: EditorState.create({ extensions: [basicSetup, ocaml,  autocompletion({override: [myCompletions]})] }),
  parent: document.getElementById('editor')
})
a
