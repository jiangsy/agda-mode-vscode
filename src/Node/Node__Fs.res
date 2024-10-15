@module("fs")
external readdir: (string, (Js.nullable<Js.Exn.t>, array<string>) => unit) => unit = "readdir"

@module("fs")
external access: (string, Js.null<Js.Exn.t> => unit) => unit = "access"
@module("fs")
external readFile: (string, (Js.nullable<Js.Exn.t>, Node.Buffer.t) => unit) => unit = "readFile"
@module("fs")
external unlink: (string, Js.nullable<Js.Exn.t> => unit) => unit = "unlink"
