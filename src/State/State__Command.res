open Belt
open Command

// from Editor Command to Tasks
let rec dispatchCommand = (state: State.t, command): Promise.t<
  result<unit, Connection.Error.t>,
> => {
  let dispatchCommand = dispatchCommand(state)
  let sendAgdaRequest = State.sendRequest(state, State__Response.handle(state, dispatchCommand))
  let header = View.Header.Plain(Command.toString(command))
  switch command {
  | Load =>
    State.View.DebugBuffer.restore(state)
    ->Promise.flatMap(() => State.View.Panel.display(state, Plain("Loading ..."), []))
    ->Promise.flatMap(() => {
      // save the document before loading
      VSCode.TextDocument.save(state.document)
    })
    ->Promise.flatMap(_ => {
      // Issue #26 - don't load the document in preview mode
      let options = Some(VSCode.TextDocumentShowOptions.make(~preview=false, ()))
      VSCode.Window.showTextDocumentWithShowOptions(state.document, options)->Promise.flatMap(_ =>
        sendAgdaRequest(Load)
      )
    })
  | Quit => Promise.resolved(Ok())
  | Restart =>
    // clear the RunningInfo log
    state.runningInfoLog = []
    dispatchCommand(Load)
  | Refresh =>
    state.highlighting->Highlighting.redecorate(state.editor)
    State.View.Panel.restore(state)
    State__Goal.redecorate(state)
    State.View.DebugBuffer.restore(state)->Promise.map(() => Ok())
  | Compile => sendAgdaRequest(Compile)
  | ToggleDisplayOfImplicitArguments => sendAgdaRequest(ToggleDisplayOfImplicitArguments)
  | ToggleDisplayOfIrrelevantArguments => sendAgdaRequest(ToggleDisplayOfIrrelevantArguments)
  | ShowConstraints => sendAgdaRequest(ShowConstraints)
  | SolveConstraints(normalization) =>
    switch State__Goal.pointed(state) {
    | None => sendAgdaRequest(SolveConstraintsGlobal(normalization))
    | Some((goal, _)) => sendAgdaRequest(SolveConstraints(normalization, goal))
    }
  | ShowGoals(normalization) => sendAgdaRequest(ShowGoals(normalization))
  | NextGoal => State__Goal.next(state)->Promise.map(() => Ok())
  | PreviousGoal => State__Goal.previous(state)->Promise.map(() => Ok())
  | SearchAbout(normalization) =>
    State.View.Panel.prompt(
      state,
      header,
      {body: None, placeholder: Some("name:"), value: None},
      expr => sendAgdaRequest(SearchAbout(normalization, expr)),
    )->Promise.map(() => Ok())
  | Give =>
    switch State__Goal.pointed(state) {
    | None => State.View.Panel.displayOutOfGoalError(state)->Promise.map(() => Ok())
    | Some((goal, "")) =>
      State.View.Panel.prompt(
        state,
        header,
        {
          body: None,
          placeholder: Some("expression to give:"),
          value: None,
        },
        expr =>
          if expr == "" {
            sendAgdaRequest(Give(goal))
          } else {
            State__Goal.modify(state, goal, _ => expr)->Promise.flatMap(() =>
              sendAgdaRequest(Give(goal))
            )
          },
      )->Promise.map(() => Ok())
    | Some((goal, _)) => sendAgdaRequest(Give(goal))
    }
  | Refine =>
    switch State__Goal.pointed(state) {
    | None => State.View.Panel.displayOutOfGoalError(state)->Promise.map(() => Ok())
    | Some((goal, _)) => sendAgdaRequest(Refine(goal))
    }
  | ElaborateAndGive(normalization) => {
      let placeholder = Some("expression to elaborate and give:")
      switch State__Goal.pointed(state) {
      | None => State.View.Panel.displayOutOfGoalError(state)->Promise.map(() => Ok())
      | Some((goal, "")) =>
        State.View.Panel.prompt(
          state,
          header,
          {
            body: None,
            placeholder,
            value: None,
          },
          expr =>
            if expr == "" {
              sendAgdaRequest(ElaborateAndGive(normalization, expr, goal))
            } else {
              State__Goal.modify(state, goal, _ => expr)->Promise.flatMap(() =>
                sendAgdaRequest(ElaborateAndGive(normalization, expr, goal))
              )
            },
        )->Promise.map(() => Ok())
      | Some((goal, expr)) => sendAgdaRequest(ElaborateAndGive(normalization, expr, goal))
      }
    }
  | Auto =>
    switch State__Goal.pointed(state) {
    | None => State.View.Panel.displayOutOfGoalError(state)->Promise.map(() => Ok())
    | Some((goal, _)) => sendAgdaRequest(Auto(goal))
    }
  | Case => {
      let placeholder = Some("variable to case split:")
      switch State__Goal.pointed(state) {
      | None => State.View.Panel.displayOutOfGoalError(state)->Promise.map(() => Ok())
      | Some((goal, "")) =>
        State.View.Panel.prompt(
          state,
          header,
          {
            body: Some("Please specify which variable you wish to split"),
            placeholder,
            value: None,
          },
          expr =>
            if expr == "" {
              sendAgdaRequest(Case(goal))
            } else {
              // place the queried expression in the goal
              State__Goal.modify(state, goal, _ => expr)->Promise.flatMap(_ =>
                sendAgdaRequest(Case(goal))
              )
            },
        )->Promise.map(() => Ok())
      | Some((goal, _)) => sendAgdaRequest(Case(goal))
      }
    }
  | HelperFunctionType(normalization) => {
      let placeholder = Some("expression:")
      switch State__Goal.pointed(state) {
      | None => State.View.Panel.displayOutOfGoalError(state)->Promise.map(() => Ok())
      | Some((goal, "")) =>
        State.View.Panel.prompt(
          state,
          header,
          {
            body: None,
            placeholder,
            value: None,
          },
          expr => sendAgdaRequest(HelperFunctionType(normalization, expr, goal)),
        )->Promise.map(() => Ok())
      | Some((goal, expr)) => sendAgdaRequest(HelperFunctionType(normalization, expr, goal))
      }
    }
  | InferType(normalization) =>
    let placeholder = Some("expression to infer:")
    switch State__Goal.pointed(state) {
    | None =>
      State.View.Panel.prompt(
        state,
        header,
        {
          body: None,
          placeholder,
          value: None,
        },
        expr => sendAgdaRequest(InferTypeGlobal(normalization, expr)),
      )->Promise.map(() => Ok())
    | Some((goal, "")) =>
      State.View.Panel.prompt(
        state,
        header,
        {
          body: None,
          placeholder,
          value: None,
        },
        expr => sendAgdaRequest(InferType(normalization, expr, goal)),
      )->Promise.map(() => Ok())
    | Some((goal, expr)) => sendAgdaRequest(InferType(normalization, expr, goal))
    }
  | Context(normalization) =>
    switch State__Goal.pointed(state) {
    | None => State.View.Panel.displayOutOfGoalError(state)->Promise.map(() => Ok())
    | Some((goal, _)) => sendAgdaRequest(Context(normalization, goal))
    }
  | GoalType(normalization) =>
    switch State__Goal.pointed(state) {
    | None => State.View.Panel.displayOutOfGoalError(state)->Promise.map(() => Ok())
    | Some((goal, _)) => sendAgdaRequest(GoalType(normalization, goal))
    }
  | GoalTypeAndContext(normalization) =>
    switch State__Goal.pointed(state) {
    | None => State.View.Panel.displayOutOfGoalError(state)->Promise.map(() => Ok())
    | Some((goal, _)) => sendAgdaRequest(GoalTypeAndContext(normalization, goal))
    }
  | GoalTypeContextAndInferredType(normalization) =>
    switch State__Goal.pointed(state) {
    | None => State.View.Panel.displayOutOfGoalError(state)->Promise.map(() => Ok())
    | Some((goal, "")) =>
      // fallback to `GoalTypeAndContext` when there's no content
      sendAgdaRequest(GoalTypeAndContext(normalization, goal))
    | Some((goal, expr)) =>
      sendAgdaRequest(GoalTypeContextAndInferredType(normalization, expr, goal))
    }
  | GoalTypeContextAndCheckedType(normalization) =>
    let placeholder = Some("expression to type:")
    switch State__Goal.pointed(state) {
    | None => State.View.Panel.displayOutOfGoalError(state)->Promise.map(() => Ok())
    | Some((goal, "")) =>
      State.View.Panel.prompt(
        state,
        header,
        {
          body: None,
          placeholder,
          value: None,
        },
        expr => sendAgdaRequest(GoalTypeContextAndCheckedType(normalization, expr, goal)),
      )->Promise.map(() => Ok())
    | Some((goal, expr)) =>
      sendAgdaRequest(GoalTypeContextAndCheckedType(normalization, expr, goal))
    }
  | ModuleContents(normalization) =>
    let placeholder = Some("module name:")
    switch State__Goal.pointed(state) {
    | None =>
      State.View.Panel.prompt(
        state,
        header,
        {
          body: None,
          placeholder,
          value: None,
        },
        expr => sendAgdaRequest(ModuleContentsGlobal(normalization, expr)),
      )->Promise.map(() => Ok())
    | Some((goal, "")) =>
      State.View.Panel.prompt(
        state,
        header,
        {
          body: None,
          placeholder,
          value: None,
        },
        expr => sendAgdaRequest(ModuleContents(normalization, expr, goal)),
      )->Promise.map(() => Ok())
    | Some((goal, expr)) => sendAgdaRequest(ModuleContents(normalization, expr, goal))
    }
  | ComputeNormalForm(computeMode) =>
    let placeholder = Some("expression to normalize:")
    switch State__Goal.pointed(state) {
    | None =>
      State.View.Panel.prompt(
        state,
        header,
        {
          body: None,
          placeholder,
          value: None,
        },
        expr => sendAgdaRequest(ComputeNormalFormGlobal(computeMode, expr)),
      )->Promise.map(() => Ok())
    | Some((goal, "")) =>
      State.View.Panel.prompt(
        state,
        header,
        {
          body: None,
          placeholder,
          value: None,
        },
        expr => sendAgdaRequest(ComputeNormalForm(computeMode, expr, goal)),
      )->Promise.map(() => Ok())
    | Some((goal, expr)) => sendAgdaRequest(ComputeNormalForm(computeMode, expr, goal))
    }
  | WhyInScope =>
    let placeholder = Some("name:")
    switch State__Goal.pointed(state) {
    | None =>
      State.View.Panel.prompt(
        state,
        header,
        {
          body: None,
          placeholder,
          value: None,
        },
        expr => sendAgdaRequest(WhyInScopeGlobal(expr)),
      )->Promise.map(() => Ok())
    | Some((goal, "")) =>
      State.View.Panel.prompt(
        state,
        header,
        {
          body: None,
          placeholder,
          value: None,
        },
        expr => sendAgdaRequest(WhyInScope(expr, goal)),
      )->Promise.map(() => Ok())
    | Some((goal, expr)) => sendAgdaRequest(WhyInScope(expr, goal))
    }
  | SwitchAgdaVersion =>
    // preserve the original version, in case the new one fails
    let oldAgdaVersion = Config.Connection.getAgdaVersion()
    // prompt the user for the new version
    State.View.Panel.prompt(
      state,
      header,
      {
        body: None,
        placeholder: None,
        value: Some(oldAgdaVersion),
      },
      expr => {
        let oldAgdaPath = Config.Connection.getAgdaPath()
        let newAgdaVersion = Js.String.trim(expr)
        // don't connect to the LSP server
        let useLSP = false

        Config.Connection.setAgdaPath("")
        // set the name of executable to `newAgdaVersion` in the settings
        ->Promise.flatMap(() => Config.Connection.setAgdaVersion(newAgdaVersion))
        ->Promise.flatMap(() =>
          State.View.Panel.display(
            state,
            View.Header.Plain("Switching to '" ++ newAgdaVersion ++ "'"),
            [],
          )
        )
        // stop the old connection
        ->Promise.flatMap(Connection.stop)
        ->Promise.flatMap(_ =>
          Connection.start(state.globalStoragePath, useLSP, State.onDownload(state))
        )
        ->Promise.flatMap(result =>
          switch result {
          | Ok(Emacs(version, path)) =>
            // update the connection status
            State.View.Panel.displayStatus(state, "Emacs v" ++ version)
            ->Promise.flatMap(
              () =>
                State.View.Panel.display(
                  state,
                  View.Header.Success("Switched to version '" ++ version ++ "'"),
                  [Item.plainText("Found '" ++ newAgdaVersion ++ "' at: " ++ path)],
                ),
            )
            ->Promise.map(() => Ok())

          | Ok(LSP(version, _)) =>
            // should not happen
            State.View.Panel.display(
              state,
              View.Header.Success("Panic, Switched to LSP server '" ++ version ++ "'"),
              [Item.plainText("Should have switched to an Agda executable, please file an issue")],
            )->Promise.map(() => Ok())
          | Error(error) =>
            let (errorHeader, errorBody) = Connection.Error.toString(error)
            let header = View.Header.Error(
              "Cannot switch Agda version '" ++ newAgdaVersion ++ "' : " ++ errorHeader,
            )
            let body = [Item.plainText(errorBody ++ "\n\n" ++ "Switching back to " ++ oldAgdaPath)]
            Config.Connection.setAgdaPath(oldAgdaPath)
            ->Promise.flatMap(() => State.View.Panel.display(state, header, body))
            ->Promise.map(() => Ok())
          }
        )
      },
    )->Promise.map(() => Ok())
  | EventFromView(event) =>
    switch event {
    | Initialized => Promise.resolved(Ok())
    | Destroyed => State.destroy(state, true)
    | InputMethod(InsertChar(char)) => dispatchCommand(InputMethod(InsertChar(char)))
    | InputMethod(ChooseSymbol(symbol)) =>
      State__InputMethod.chooseSymbol(state, symbol)->Promise.map(() => Ok())
    | PromptIMUpdate(MouseSelect(interval)) =>
      State__InputMethod.select(state, [interval])->Promise.map(() => Ok())
    | PromptIMUpdate(KeyUpdate(input)) =>
      State__InputMethod.keyUpdatePromptIM(state, input)->Promise.map(() => Ok())
    | PromptIMUpdate(BrowseUp) => dispatchCommand(InputMethod(BrowseUp))
    | PromptIMUpdate(BrowseDown) => dispatchCommand(InputMethod(BrowseDown))
    | PromptIMUpdate(BrowseLeft) => dispatchCommand(InputMethod(BrowseLeft))
    | PromptIMUpdate(BrowseRight) => dispatchCommand(InputMethod(BrowseRight))
    | PromptIMUpdate(Escape) =>
      if state.editorIM->IM.isActivated || state.promptIM->IM.isActivated {
        State__InputMethod.deactivate(state)->Promise.map(() => Ok())
      } else {
        State.View.Panel.interruptPrompt(state)->Promise.map(() => Ok())
      }
    | JumpToTarget(link) =>
      Editor.focus(state.document)
      let path = state.document->VSCode.TextDocument.fileName->Parser.filepath
      switch link {
      | SrcLoc(NoRange) => Promise.resolved(Ok())
      | SrcLoc(Range(None, _intervals)) => Promise.resolved(Ok())
      | SrcLoc(Range(Some(fileName), intervals)) =>
        let fileName = Parser.filepath(fileName)
        // Issue #44
        //  In Windows, paths from Agda start from something like "c://" while they are "C://" from VS Code
        //  We need to remove the root from the path before comparing them
        let removeRoot = path => {
          let obj = Node_path.parse(path)
          let rootLength = String.length(obj["root"])
          let newDir = Js.String.sliceToEnd(~from=rootLength, obj["dir"])
          let newObj = {
            "root": "",
            "dir": newDir,
            "ext": obj["ext"],
            "name": obj["name"],
            "base": obj["base"],
          }
          Node_path.format(newObj)
        }
        let ranges = intervals->Array.map(Editor.Range.fromAgdaInterval)
        let adjustEditor = editor => {
          Editor.Selection.setMany(editor, ranges)
          ranges[0]->Option.forEach(range => {
            editor->VSCode.TextEditor.revealRange(range, None)
          })
        }

        if removeRoot(path) == removeRoot(fileName) {
          adjustEditor(state.editor)
          Promise.resolved(Ok())
        } else {
          // TODO: check this option
          let options = Some(VSCode.TextDocumentShowOptions.make(~preview=true, ()))

          VSCode.Workspace.openTextDocumentWithFileName(fileName)
          ->Promise.map(document =>
            VSCode.Window.showTextDocumentWithShowOptions(document, options)->Promise.map(editor =>
              adjustEditor(editor)
            )
          )
          ->Promise.map(_ => Ok())
        }
      | Hole(index) =>
        let goal = Js.Array.find((goal: Goal.t) => goal.index == index, state.goals)
        switch goal {
        | None => ()
        | Some(goal) => Goal.setCursor(goal, state.editor)
        }
        Promise.resolved(Ok())
      }
    }
  | Escape =>
    if state.editorIM->IM.isActivated || state.promptIM->IM.isActivated {
      State__InputMethod.deactivate(state)->Promise.map(() => Ok())
    } else {
      State.View.Panel.interruptPrompt(state)->Promise.map(() => Ok())
    }
  | InputMethod(Activate) =>
    if Config.InputMethod.getEnable() {
      State__InputMethod.activateEditorIM(state)->Promise.map(() => Ok())
    } else {
      // insert the activation key (default: "\") instead
      let activationKey = Config.InputMethod.getActivationKey()
      Editor.Cursor.getMany(state.editor)->Array.forEach(point =>
        Editor.Text.insert(state.document, point, activationKey)->ignore
      )
      Promise.resolved(Ok())
    }

  | InputMethod(InsertChar(char)) =>
    State__InputMethod.insertChar(state, char)->Promise.map(() => Ok())
  | InputMethod(BrowseUp) => State__InputMethod.moveUp(state)->Promise.map(() => Ok())
  | InputMethod(BrowseDown) => State__InputMethod.moveDown(state)->Promise.map(() => Ok())
  | InputMethod(BrowseLeft) => State__InputMethod.moveLeft(state)->Promise.map(() => Ok())
  | InputMethod(BrowseRight) => State__InputMethod.moveRight(state)->Promise.map(() => Ok())
  | LookupSymbol =>
    // get the selected text
    // query the user instead if no text is selected
    let (promise, resolve) = Promise.pending()
    let selectedText =
      Editor.Text.get(state.document, Editor.Selection.get(state.editor))->Js.String.trim
    if selectedText == "" {
      State.View.Panel.prompt(
        state,
        View.Header.Plain("Lookup Unicode Symbol Input Sequence"),
        {body: None, placeholder: Some("symbol to lookup:"), value: None},
        input => {
          resolve(Js.String.trim(input))
          Promise.resolved(Ok())
        },
      )->ignore
    } else {
      resolve(selectedText)
    }

    // lookup and display
    promise
    ->Promise.flatMap(input => {
      let sequences = Translator.lookup(input)->Option.getWithDefault([])
      if Js.Array.length(sequences) == 0 {
        State.View.Panel.display(
          state,
          View.Header.Warning("No Input Sequences Found for \"" ++ selectedText ++ "\""),
          [],
        )
      } else {
        State.View.Panel.display(
          state,
          View.Header.Success(
            string_of_int(Js.Array.length(sequences)) ++
            " Input Sequences Found for \"" ++
            selectedText ++ "\"",
          ),
          sequences->Array.map(sequence => Item.plainText(sequence)),
        )
      }
    })
    ->Promise.map(() => Ok())
  | OpenDebugBuffer =>
    State.View.DebugBuffer.make(state)->ignore
    State.View.DebugBuffer.reveal(state)->Promise.map(() => Ok())
  }
}
