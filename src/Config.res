open VSCode
module VSRange = Range
open Belt

// this flag should be set as TRUE when testing
let inTestingMode = ref(false)

module Connection = {
  // in testing mode, configs are read and written from here instead
  let agdaVersionInTestingMode = ref("agda")
  let agdaPathInTestingMode = ref("")
  let useAgdaLanguageServerInTestingMode = ref(false)

  // Agda version
  let setAgdaVersion = path =>
    if inTestingMode.contents {
      agdaVersionInTestingMode := path
      Promise.resolved()
    } else {
      Workspace.getConfiguration(
        Some("agdaMode"),
        None,
      )->WorkspaceConfiguration.updateGlobalSettings("connection.agdaVersion", path, None)
    }

  let getAgdaVersion = () =>
    if inTestingMode.contents {
      agdaVersionInTestingMode.contents
    } else {
      Workspace.getConfiguration(Some("agdaMode"), None)
      ->WorkspaceConfiguration.get("connection.agdaVersion")
      ->Option.map(Js.String.trim)
      ->Option.flatMap(s => s == "" ? None : Some(s))
      ->Option.getWithDefault("agda")
    }

  // Agda path
  let setAgdaPath = path =>
    if inTestingMode.contents {
      agdaPathInTestingMode := path
      Promise.resolved()
    } else {
      Workspace.getConfiguration(
        Some("agdaMode"),
        None,
      )->WorkspaceConfiguration.updateGlobalSettings("connection.agdaPath", path, None)
    }
  let getAgdaPath = () =>
    if inTestingMode.contents {
      agdaPathInTestingMode.contents
    } else {
      Workspace.getConfiguration(Some("agdaMode"), None)
      ->WorkspaceConfiguration.get("connection.agdaPath")
      ->Option.mapWithDefault("", Js.String.trim)
    }

  // Agda command-line options
  let getCommandLineOptions = () =>
    Workspace.getConfiguration(Some("agdaMode"), None)
    ->WorkspaceConfiguration.get("connection.commandLineOptions")
    ->Option.mapWithDefault([], s => Js.String.split(" ", Js.String.trim(s)))
    ->Array.keep(s => Js.String.trim(s) != "")

  // Agda Language Server
  let getUseAgdaLanguageServer = () =>
    if inTestingMode.contents {
      useAgdaLanguageServerInTestingMode.contents
    } else {
      let raw =
        Workspace.getConfiguration(Some("agdaMode"), None)->WorkspaceConfiguration.get(
          "connection.agdaLanguageServer",
        )
      switch raw {
      | Some(true) => true
      | _ => false
      }
    }
  let setUseAgdaLanguageServer = (mode: bool) =>
    if inTestingMode.contents {
      useAgdaLanguageServerInTestingMode := mode
      Promise.resolved()
    } else {
      Workspace.getConfiguration(
        Some("agdaMode"),
        None,
      )->WorkspaceConfiguration.updateGlobalSettings("connection.agdaLanguageServer", mode, None)
    }
  // Agda Language Server port
  let getAgdaLanguageServerPort = () => {
    let raw =
      Workspace.getConfiguration(Some("agdaMode"), None)->WorkspaceConfiguration.get(
        "connection.agdaLanguageServerPort",
      )
    switch raw {
    | Some(port) => port
    | _ => 4096
    }
  }

  // Agda Language Server command-line options
  let getAgdaLanguageServerCommandLineOptions = () =>
    Workspace.getConfiguration(Some("agdaMode"), None)
    ->WorkspaceConfiguration.get("connection.agdaLanguageServerOptions")
    ->Option.mapWithDefault([], s => Js.String.split(" ", Js.String.trim(s)))
    ->Array.keep(s => Js.String.trim(s) != "")
}

module View = {
  // Panel mounting position
  type mountAt = Bottom | Right
  let setPanelMountingPosition = mountAt =>
    Workspace.getConfiguration(Some("agdaMode"), None)->WorkspaceConfiguration.updateGlobalSettings(
      "view.panelMountPosition",
      switch mountAt {
      | Bottom => "bottom"
      // | Left => "left"
      | Right => "right"
      },
      None,
    )
  let getPanelMountingPosition = () => {
    let result =
      Workspace.getConfiguration(Some("agdaMode"), None)->WorkspaceConfiguration.get(
        "view.panelMountPosition",
      )
    switch result {
    // | Some("left") => Left
    | Some("right") => Right
    | _ => Bottom
    }
  }
}
// Library path
let getLibraryPath = () => {
  let raw =
    Workspace.getConfiguration(Some("agdaMode"), None)
    ->WorkspaceConfiguration.get("libraryPath")
    ->Option.getWithDefault("")
  // split by comma, and clean them up
  Js.String.split(",", raw)->Array.keep(x => x !== "")->Array.map(Parser.filepath)
}

module Highlighting = {
  // Highlighting method
  // let getSemanticHighlighting = () => {
  //   let raw =
  //     Workspace.getConfiguration(Some("agdaMode"), None)->WorkspaceConfiguration.get(
  //       "highlighting.semanticHighlighting.enabled",
  //     )
  //   switch raw {
  //   | Some(true) => true
  //   | Some(false) => false
  //   | _ => true
  //   }
  // }
  let getHighlightingMethod = () => {
    let raw =
      Workspace.getConfiguration(Some("agdaMode"), None)->WorkspaceConfiguration.get(
        "highlighting.IPC",
      )
    switch raw {
    | Some("Standard input/output") => true
    | _ => false
    }
  }
  // Highlight stuff with theme colors (LSP Semantic Highlighting)
  let getHighlightWithThemeColors = () => {
    let raw =
      Workspace.getConfiguration(Some("agdaMode"), None)->WorkspaceConfiguration.get(
        "highlighting.getHighlightWithThemeColors",
      )
    switch raw {
    | Some(true) => true
    | Some(false) => false
    | _ => true
    }
  }
}

// Backend
let getBackend = () => {
  let raw =
    Workspace.getConfiguration(Some("agdaMode"), None)->WorkspaceConfiguration.get("backend")
  switch raw {
  | Some("GHC") => "GHCNoMain"
  | Some("LaTeX") => "LaTeX"
  | Some("QuickLaTeX") => "QuickLaTeX"
  | _ => "GHCNoMain"
  }
}

module InputMethod = {
  let getEnable = () => {
    let raw =
      Workspace.getConfiguration(Some("agdaMode"), None)->WorkspaceConfiguration.get(
        "inputMethod.enable",
      )
    switch raw {
    | Some(true) => true
    | Some(false) => false
    | _ => true // enabled by default
    }
  }
  let getActivationKey = () => {
    let raw =
      Workspace.getConfiguration(Some("agdaMode"), None)->WorkspaceConfiguration.get(
        "inputMethod.activationKey",
      )
    switch raw {
    | Some(s) =>
      switch Js.String.substrAtMost(~from=0, ~length=1, s) {
      | "" => "\\"
      | key => key
      }
    | _ => "\\"
    }
  }
}
