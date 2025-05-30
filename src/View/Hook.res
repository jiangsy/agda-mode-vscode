// React Hook for request-response handling
let recv = (reqChan: Chan.t<'req>, resChan: Chan.t<'res>, handler: 'req => promise<'res>) =>
  React.useEffect1(() => Some(
    reqChan->Chan.on(req => {
      handler(req)->Promise.thenResolve(res => resChan->Chan.emit(res))->Promise.done
    }),
  ), [])

// React Hook for receiving events
let on = (chan: Chan.t<'a>, handler: 'a => unit) =>
  React.useEffect1(() => Some(chan->Chan.on(handler)), [])

let useFocus = () => {
  let htmlElRef = React.useRef(Nullable.null)
  let setFocus = _ => {
    htmlElRef.current
    ->Nullable.toOption
    ->Option.flatMap(Webapi.Dom.Element.asHtmlElement)
    ->Option.forEach(Webapi.Dom.HtmlElement.focus)
  }
  (htmlElRef, setFocus)
}
