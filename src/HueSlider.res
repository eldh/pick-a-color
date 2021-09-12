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
      for hue in 0 to 500 {
        ctx["fillStyle"] = Lab.hslToP3(#hsl(hue->float_of_int /. 500., 1., 0.5))->Lab.p3ToString
        ctx["fillRect"](. hue, 0, 1, 40)
      }
    })
    None
  }, [])
  // Js.log(value)
  let canvasLeftEdge =
    canvasRef.current
    ->Js.Nullable.toOption
    ->Belt.Option.map(c => c["getBoundingClientRect"](.)["x"])
    ->Belt.Option.getWithDefault(0)
  <>
    <Wrapper
      onMouseMove={e => {
        if mouseDown {
          let mouseX = e->ReactEvent.Mouse.clientX
          setValue(_ => (mouseX - canvasLeftEdge)->clamp(0, 500)->float_of_int /. 500.)
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
        let mouseX = e->ReactEvent.Mouse.clientX
        Js.log3("mouseX", canvasLeftEdge, mouseX)
        setValue(_ => (mouseX - canvasLeftEdge)->clamp(0, 500)->float_of_int /. 500.)
        setMouseDown(_ => true)

        ()
      }}>
      {mouseDown ? <div className={Styles.mouseBg} /> : React.null}
      <canvas ref={ReactDOM.Ref.domRef(canvasRef->Obj.magic)} width="500" height="40" />
      <div className={Styles.point((value *. 500.)->Belt.Float.toInt)} />
    </Wrapper>
  </>
}
