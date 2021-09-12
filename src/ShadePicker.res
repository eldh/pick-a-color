type canvasContext = {@set "fillStyle": string, "fillRect": (. int, int, int, int) => unit}
type canvasEl = {"getContext": (. string) => canvasContext}
let bump = v => v +. (31.25 -. Js.Math.pow_float(~base=v -. 62.5, ~exp=2.) /. 125.)
let bumpY = v => v -. (31.25 -. Js.Math.pow_float(~base=v -. 62.5, ~exp=2.) /. 125.)
module Styles = {
  open CssJs

  let test = bg =>
    style(. [
      position(#relative),
      width(px(50)),
      height(px(50)),
      unsafe("background", bg),
      borderRadius(#px(2)),
      boxShadow(Shadow.box(~y=px(1), ~blur=px(2), rgba(0, 0, 0, #num(0.5)))),
    ])
}

@react.component
let make = (~hue, ~saturation, ~lightness, ~setSaturation, ~setLightness, ()) => {
  let canvasRef = React.useRef(Js.Nullable.null)
  React.useEffect3(() => {
    canvasRef.current
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
  }, (lightness, hue, saturation))
  <> <canvas ref={ReactDOM.Ref.domRef(canvasRef->Obj.magic)} width="500" height="500" /> </>
}
