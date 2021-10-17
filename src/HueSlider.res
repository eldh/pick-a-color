type canvasContext = {@set "fillStyle": string, "fillRect": (. int, int, int, int) => unit}
type canvasEl = {"getContext": (. string) => canvasContext}

let clamp = (v, min, max) => v->Js.Math.max_int(min)->Js.Math.min_int(max)

module Styles = {
  open CssJs

  let point = offset =>
    style(. [
      position(#relative),
      left(px(offset)),
      top(px(-2)),
      width(px(5)),
      height(px(44)),
      position(#absolute),
      backgroundColor(#hex("fffd")),
      borderRadius(#px(2)),
      backdropFilter([#brightness(#percent(150.))]),
      boxShadow(Shadow.box(~y=px(1), ~blur=px(2), rgba(0, 0, 0, #num(0.5)))),
      zIndex(10),
      before([
        contentRule(#text(" ")),
        position(#absolute),
        top(#px(0)),
        left(#px(-8)),
        width(#px(8)),
        height(#px(44)),
        zIndex(1),
      ]),
      after([
        contentRule(#text(" ")),
        position(#absolute),
        top(#px(0)),
        right(#px(-8)),
        width(#px(8)),
        height(#px(44)),
        zIndex(1),
      ]),
    ])
  let mouseBg = style(. [
    contentRule(#attr(" ")),
    position(#fixed),
    top(#px(0)),
    left(#px(0)),
    width(#vw(100.)),
    height(#vh(100.)),
    zIndex(1),
  ])
}

module Wrapper = %styled.div(`
  display: flex;
  position:relative;
  width: 500px;
  height: 40px;
`)

@react.component
let make = (~setValue, ~value: float) => {
  let canvasRef = React.useRef(Js.Nullable.null)
  let (mouseDown, setMouseDown) = React.useState(() => false)
  React.useEffect1(() => {
    canvasRef.current
    ->Js.Nullable.toOption
    ->Belt.Option.forEach(c => {
      let ctx = c["getContext"](. "2d")
      for i in 0 to 500 {
        let deg = i->float_of_int *. 2. *. Js.Math._PI /. 500.
        ctx["fillStyle"] = #lch(75., 132., deg, 1.)->Lab.toString(P3)
        ctx["fillRect"](. i, 0, 1, 40)
      }
    })
    None
  }, [])

  let setValueFromEvent = e => {
    let canvasLeftEdge =
      canvasRef.current
      ->Js.Nullable.toOption
      ->Belt.Option.map(c => c["getBoundingClientRect"](.)["x"])
      ->Belt.Option.getWithDefault(0)
    let mouseX = e->ReactEvent.Mouse.clientX
    setValue((mouseX - canvasLeftEdge)->clamp(0, 500)->float_of_int *. 2. *. Js.Math._PI /. 500.)
  }
  <>
    <Wrapper
      onMouseMove={e => {
        if mouseDown {
          setValueFromEvent(e)
          e->ReactEvent.Mouse.preventDefault
        }
        ()
      }}
      onMouseUp={e => {
        e->ReactEvent.Mouse.preventDefault
        setMouseDown(_v => false)
        ()
      }}
      onMouseDown={e => {
        setValueFromEvent(e)
        e->ReactEvent.Mouse.preventDefault
        setMouseDown(_ => true)
        ()
      }}>
      {mouseDown ? <div className={Styles.mouseBg} /> : React.null}
      <canvas ref={ReactDOM.Ref.domRef(canvasRef->Obj.magic)} width="500" height="40" />
      <div className={Styles.point((value *. 500. /. (2. *. Js.Math._PI))->Belt.Float.toInt)} />
    </Wrapper>
  </>
}
