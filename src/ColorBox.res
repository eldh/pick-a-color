module Styles = {
  open CssJs

  let bg = color =>
    style(. [width(#percent(500. /. 9.)), height(#px(50)), unsafe("backgroundColor", color)])

  let flex = style(. [display(#flex), flexDirection(#row), width(px(500))])
}

let shades = [-15, -0, 40]

@react.component
let make = (~color) => {
  let labColor = color->Lab.toLab
  let rotations = [
    labColor->Lab.rotate(~deg=Js.Math._PI /. -1.5),
    labColor->Lab.rotate(~deg=Js.Math._PI /. -3.),
    labColor->Lab.rotate(~deg=0.),
    labColor->Lab.rotate(~deg=Js.Math._PI /. 3.),
    labColor->Lab.rotate(~deg=Js.Math._PI /. 1.5),
  ]
  <>
    {rotations
    ->Belt.Array.map(r => {
      <div className=Styles.flex>
        {shades
        ->Belt.Array.map(n => {
          <div
            key={n->Js.Int.toString}
            className={Styles.bg(r->Lab.lighten(n, _)->Lab.toP3->Lab.p3ToString)}
          />
        })
        ->React.array}
      </div>
    })
    ->React.array}
  </>
}
