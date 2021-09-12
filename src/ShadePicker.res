type canvasContext = {@set "fillStyle": string, "fillRect": (. int, int, int, int) => unit}
type canvasEl = {"getContext": (. string) => canvasContext}
let bump = v => v +. (31.25 -. Js.Math.pow_float(~base=v -. 62.5, ~exp=2.) /. 125.)

let clamp = (v, min, max) => v->Js.Math.max_int(min)->Js.Math.min_int(max)

module ShadeCanvas = {
  @react.component
  let make = (
    ~hue,
    ~domRef: React.ref<
      Js.Nullable.t<{..
        "getContext": (
          . string,
        ) => {..
          "fillRect": (. float, int, int, int) => unit,
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
          let x1 = x->float_of_int
          let x2 = x1->bump
          for y in 0 to 125 {
            let y1 = y->float_of_int
            let y2 = (y1 +. y1->bump) /. 2.
            ctx["fillStyle"] =
              Lab.hslToP3(#hsl(hue, x2 /. 125., (125. -. y2) /. 125.))->Lab.p3ToString
            ctx["fillRect"](. x1 *. 4., y * 4, 4, 4)
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
      backdropFilter([#brightness(#percent(150.))]),
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
  ~saturation: int,
  ~lightness: int,
  ~setSaturation,
  ~setLightness: (int => int) => unit,
  (),
) => {
  let canvasRef = React.useRef(Js.Nullable.null)
  let (mouseDown, setMouseDown) = React.useState(() => false)
  let ((x, y), setXY) = React.useState(_ => (saturation * 5, lightness * 5))
  let setValue = (s, l) => {
    setSaturation(_ => s)
    setLightness(_ => l)
    setXY(_ => (s, l))
  }
  let (canvasX, canvasY) =
    canvasRef.current
    ->Js.Nullable.toOption
    ->Belt.Option.map(c => (c["getBoundingClientRect"](.)["x"], c["getBoundingClientRect"](.)["y"]))
    ->Belt.Option.getWithDefault((0, 0))
  <>
    <Wrapper
      onMouseMove={e => {
        if mouseDown {
          let mouseX = e->ReactEvent.Mouse.clientX
          let mouseY = e->ReactEvent.Mouse.clientY
          setValue((mouseX - canvasX)->clamp(0, 500) / 5, (mouseY - canvasY)->clamp(0, 500) / 5)
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
        let mouseY = e->ReactEvent.Mouse.clientY
        setValue((mouseX - canvasX)->clamp(0, 500) / 5, (mouseY - canvasY)->clamp(0, 500) / 5)
        setMouseDown(_ => true)

        ()
      }}>
      {mouseDown ? <div className={Styles.mouseBg} /> : React.null}
      <ShadeCanvas domRef={canvasRef} hue />
      <div className={Styles.point(x * 5, y * 5)} />
    </Wrapper>
  </>
}
