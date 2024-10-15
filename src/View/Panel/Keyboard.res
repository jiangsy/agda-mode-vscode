open React
open Belt

type state = {
  sequence: string,
  translation: Translator.translation,
  candidateIndex: int,
}

let reducer = (state, action) =>
  switch (state, action) {
  | (_, View.EventToView.InputMethod.Activate) =>
    let translation = Translator.translate("", None)
    Some({sequence: "", translation, candidateIndex: 0})
  | (_, Deactivate) => None
  | (None, _) => None
  | (Some(_), Update(sequence, translation, candidateIndex)) =>
    Some({sequence, translation, candidateIndex})
  | (Some(state), BrowseUp) => Some({...state, candidateIndex: max(0, state.candidateIndex - 10)})
  | (Some(state), BrowseRight) =>
    Some({
      ...state,
      candidateIndex: min(
        Array.length(state.translation.candidateSymbols) - 1,
        state.candidateIndex + 1,
      ),
    })
  | (Some(state), BrowseDown) =>
    Some({
      ...state,
      candidateIndex: min(
        Array.length(state.translation.candidateSymbols) - 1,
        state.candidateIndex + 10,
      ),
    })
  | (Some(state), BrowseLeft) => Some({...state, candidateIndex: max(0, state.candidateIndex - 1)})
  }

@react.component
let make = (
  ~state: option<state>,
  ~onInsertChar: string => unit,
  ~onChooseSymbol: string => unit,
  ~prompting: bool,
) =>
  switch state {
  | None => <div className="agda-mode-keyboard deactivated" />
  | Some({sequence, translation, candidateIndex}) =>
    <div className={"agda-mode-keyboard" ++ (prompting ? " prompting" : "")}>
      <div className="agda-mode-keyboard-sequence-and-candidates">
        <div className="agda-mode-keyboard-sequence"> {string(sequence)} </div>
        <CandidateSymbols
          candidates=translation.candidateSymbols index=candidateIndex onChooseSymbol
        />
      </div>
      <div className="agda-mode-keyboard-suggestions">
        {translation.keySuggestions
        ->Array.map(key =>
          <button className="agda-mode-key" onClick={_ => onInsertChar(key)} key>
            {string(key)}
          </button>
        )
        ->array}
      </div>
    </div>
  }
