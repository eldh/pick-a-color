module Styles = {
  open CssJs

  let bg = (~textColor="#fff", color) =>
    style(. [
      display(#flex),
      fontSize(#px(28)),
      fontWeight(#bold),
      alignItems(#center),
      justifyContent(#center),
      width(#percent(500. /. 9.)),
      height(#px(50)),
      unsafe("backgroundColor", color),
      unsafe("color", textColor),
    ])

  let flex = style(. [display(#flex), flexDirection(#row), width(px(500))])
}

let shades = [-35, -0, 40]

@react.component
let make = (~color) => {
  let labColor = color->Lab.toLab
  let rotations = [labColor->Lab.rotate(~deg=0.)]
  <>
    {rotations
    ->Belt.Array.map(r => {
      <div className=Styles.flex>
        {shades
        ->Belt.Array.map(n => {
          <div
            key={n->Js.Int.toString}
            className={Styles.bg(
              ~textColor=r
              ->Lab.lighten(n, _)
              ->Lab.getContrastColor(~tint=color->Lab.desaturate(~amount=0.7))
              ->Lab.toP3
              ->Lab.p3ToString,
              r->Lab.lighten(n, _)->Lab.toP3->Lab.p3ToString,
            )}>
            {"Boom"->React.string}
          </div>
        })
        ->React.array}
      </div>
    })
    ->React.array}
  </>
}
