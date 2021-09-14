type canvasContext = {@set "fillStyle": string, "fillRect": (. int, int, int, int) => unit}
type canvasEl = {"getContext": (. string) => canvasContext}

let clamp = (v, min, max) => v->Js.Math.max_int(min)->Js.Math.min_int(max)

module Styles = {
  open CssJs

  let bg = color =>
    style(. [width(#px(100)), height(#px(100)), unsafe("background-color", color->Lab.p3ToString)])
}

@react.component
let make = (~color) => {
  <div className={Styles.bg(color)} />
}
