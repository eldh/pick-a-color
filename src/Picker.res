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
let make = () => {
  let (lightness, setLightness) = React.useState(() => 100)
  let (saturation, setSaturation) = React.useState(() => 100)
  let (hue, setHue) = React.useState(() => 0.)

  <>
    <ShadePicker hue saturation lightness setSaturation setLightness />
    <HueSlider value=hue setValue=setHue />
  </>
}
