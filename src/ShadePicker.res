type canvasContext = {@set "fillStyle": string, "fillRect": (. int, int, int, int) => unit}
type canvasEl = {"getContext": (. string) => canvasContext}

let size = 500.
let points = 125.
let pointsInt = points->int_of_float
let pointSize = size /. points
let pointSizeInt = pointSize->int_of_float

// Just use linear for now
let xToChroma = (~max as _=points, x) => x
let chromaToX = (~max as _=points, x) => x
// let xToChroma = (~max=points, x) => 2. *. x -. x *. x /. max
// let chromaToX = (~max=points, x) => max -. Js.Math.sqrt(max *. max -. max *. x)

// Just use linear for now
let yToLightness = (~max as _=points, x) => x
let lightnessToY = (~max as _=points, x) => x

let clamp = (v, min, max) => v->Js.Math.max_float(min)->Js.Math.min_float(max)

module ShadeCanvas = {
  @react.component
  let make = (
    ~hue,
    ~domRef: React.ref<
      Js.Nullable.t<{..
        "getContext": (
          . string,
        ) => {..
          "fillRect": (. int, int, int, int) => unit,
          "fillStyle#=": Js_OO.Meth.arity1<string => unit>,
        },
      }>,
    >,
    (),
  ) => {
    React.useLayoutEffect1(() => {
      domRef.current
      ->Js.Nullable.toOption
      ->Belt.Option.forEach(c => {
        let ctx = c["getContext"](. "2d")
        for x in 0 to pointsInt {
          for y in 0 to pointsInt {
            ctx["fillStyle"] =
              #lch(
                100. *. (1. -. y->float_of_int->yToLightness /. points),
                x->float_of_int->xToChroma *. 132. /. points,
                hue,
                1.,
              )->Lab.toString(P3)
            ctx["fillRect"](. x * pointSizeInt, y * pointSizeInt, pointSizeInt, pointSizeInt)
          }
        }
      })
      None
    }, [hue])
    <canvas ref={ReactDOM.Ref.domRef(domRef->Obj.magic)} width="500" height="500" />
  }
}
module Styles = {
  open CssJs

  let point = (x, y) =>
    style(. [
      position(#relative),
      left(px(x - 7)),
      top(px(y - 7)),
      width(px(14)),
      height(px(14)),
      position(#absolute),
      borderColor(#hex("fff")),
      borderStyle(#solid),
      borderWidth(#px(1)),
      borderRadius(#px(10)),
      boxShadow(Shadow.box(~y=px(0), ~blur=px(4), rgba(0, 0, 0, #num(0.5)))),
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
  let wrapper = style(. [display(#flex), position(#relative), width(#px(500)), height(#px(500))])
}

@react.component
let make = (
  ~hue,
  ~chroma: float,
  ~lightness: float,
  ~setChroma,
  ~setLightness: (float => float) => unit,
  (),
) => {
  let canvasRef = React.useRef(Js.Nullable.null)
  let (mouseDown, setMouseDown) = React.useState(() => false)
  let (_isPending, startTransition) = ReactExperimental.useTransition({timeoutMs: 2000})
  let ((x, y), setXY) = React.useState(_ => {
    (
      (chroma *. 500. /. 132.)->chromaToX(~max=500.),
      (500. -. 5. *. lightness)->lightnessToY(~max=500.),
    )
  })
  let setValue = (x, y) => {
    setXY(_ => (x, y))
    startTransition(() => {
      setChroma(_ => 132. *. x->xToChroma(~max=500.) /. 500.)
      setLightness(_ => 100. -. y->yToLightness(~max=500.) /. 5.)
    })
  }

  let handleMouseEvent = e => {
    let (canvasX, canvasY) =
      canvasRef.current
      ->Js.Nullable.toOption
      ->Belt.Option.map(c => (
        c["getBoundingClientRect"](.)["x"],
        c["getBoundingClientRect"](.)["y"],
      ))
      ->Belt.Option.getWithDefault((0., 0.))
    e->ReactEvent.Mouse.preventDefault
    let mouseX = e->ReactEvent.Mouse.clientX->float_of_int
    let mouseY = e->ReactEvent.Mouse.clientY->float_of_int
    setValue((mouseX -. canvasX)->clamp(0., 500.), (mouseY -. canvasY)->clamp(0., 500.))
    setMouseDown(_ => true)

    ()
  }
  <div
    className=Styles.wrapper
    onMouseMove={e => {
      if mouseDown {
        handleMouseEvent(e)
      }
    }}
    onMouseDown={handleMouseEvent}
    onMouseUp={e => {
      e->ReactEvent.Mouse.preventDefault
      setMouseDown(_v => false)
      ()
    }}>
    {mouseDown ? <div className={Styles.mouseBg} /> : React.null}
    <ShadeCanvas domRef={canvasRef} hue />
    <div className={Styles.point(x->int_of_float, y->int_of_float)} />
  </div>
}
