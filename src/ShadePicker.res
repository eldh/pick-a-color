type canvasContext = {@set "fillStyle": string, "fillRect": (. int, int, int, int) => unit}
type canvasEl = {"getContext": (. string) => canvasContext}

let xToSaturation = (~max=125., v) =>
  v +. (max /. 4. -. Js.Math.pow_float(~base=v -. max /. 2., ~exp=2.) /. max)

let yToLightness = (~max=125., v) => (v +. v->xToSaturation(~max)) /. 2.

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
    React.useEffect1(() => {
      domRef.current
      ->Js.Nullable.toOption
      ->Belt.Option.forEach(c => {
        let ctx = c["getContext"](. "2d")
        for x in 0 to 125 {
          let x1 = x->float_of_int->xToSaturation
          for y in 0 to 125 {
            let y1 = y->float_of_int->yToLightness

            ctx["fillStyle"] =
              Lab.hslToP3(#hsl(hue, x1 /. 125., (125. -. y1) /. 125.))->Lab.p3ToString
            ctx["fillRect"](. x * 4, y * 4, 4, 4)
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
      // backdropFilter([#brightness(#percent(150.))]),
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
}

module Wrapper = %styled.div(`
  display: flex;
  position:relative;
  width: 500px;
  height: 500px;
`)

@react.component
let make = (
  ~hue,
  ~saturation: float,
  ~lightness: float,
  ~setSaturation,
  ~setLightness: (float => float) => unit,
  (),
) => {
  let canvasRef = React.useRef(Js.Nullable.null)
  let (mouseDown, setMouseDown) = React.useState(() => false)
  let ((x, y), setXY) = React.useState(_ => (saturation *. 500., lightness *. 500.))
  let setValue = (x, y) => {
    setSaturation(_ => x->xToSaturation(~max=500.) /. 500.)
    setLightness(_ => 1. -. y->yToLightness(~max=500.) /. 500.)
    setXY(_ => (x, y))
  }

  let (canvasX, canvasY) =
    canvasRef.current
    ->Js.Nullable.toOption
    ->Belt.Option.map(c => (c["getBoundingClientRect"](.)["x"], c["getBoundingClientRect"](.)["y"]))
    ->Belt.Option.getWithDefault((0., 0.))

  let handleMouseEvent = e => {
    let mouseX = e->ReactEvent.Mouse.clientX->float_of_int
    let mouseY = e->ReactEvent.Mouse.clientY->float_of_int
    setValue((mouseX -. canvasX)->clamp(0., 500.), (mouseY -. canvasY)->clamp(0., 500.))
    setMouseDown(_ => true)

    ()
  }
  <>
    <Wrapper
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
    </Wrapper>
  </>
}
