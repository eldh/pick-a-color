module Styles = {
  open CssJs

  let wrapper = (~color) =>
    style(. [
      display(#flex),
      justifyContent(#spaceBetween),
      alignItems(#stretch),
      alignContent(#stretch),
      flexDirection(#column),
      minWidth(#px(300)),
      unsafe("backgroundColor", color),
      width(#percent(100.)),
      padding(#px(40)),
    ])

  let shade = (~textColor="#fff", color) =>
    style(. [
      display(#flex),
      fontSize(#px(28)),
      fontWeight(#bold),
      flexGrow(0.),
      alignItems(#center),
      justifyContent(#center),
      width(#px(40)),
      height(#px(40)),
      unsafe("backgroundColor", color),
      unsafe("color", textColor),
    ])
  let posShades = style(. [
    display(#flex),
    fontSize(#px(28)),
    fontWeight(#bold),
    flexGrow(0.),
    alignItems(#center),
    justifyContent(#center),
    unsafe("gap", "10px"),
  ])

  let flex = style(. [display(#flex), flexDirection(#columnReverse), flexGrow(1.)])
}

let shades = [-35, -10, -0, 10, 40]
let posShades = [5, 10, 15, 25, 35, 45]
let negShades = [-45, -35, -25, -15, -10, -5]

@react.component
let make = (~color, ~onDelete, ~onEdit as _) => {
  let labColor = color->Lab.toLab
  <div
    className={Styles.wrapper(~color=color->Obj.magic->Lab.toP3->Lab.p3ToString)}
    onClick={_ => onDelete()}>
    <div className=Styles.posShades key={labColor->Lab.toP3->Lab.p3ToString}>
      {posShades
      ->Belt.Array.map(n => {
        <div
          key={n->Js.Int.toString}
          className={Styles.shade(
            ~textColor=color
            ->Lab.getContrastColor(~tint=color->Lab.desaturate(~amount=0.7))
            ->Lab.toP3
            ->Lab.p3ToString,
            color->Lab.lighten(n, _)->Lab.toP3->Lab.p3ToString,
          )}
        />
      })
      ->React.array}
    </div>
    <div className=Styles.posShades key={labColor->Lab.toP3->Lab.p3ToString}>
      {negShades
      ->Belt.Array.map(n => {
        <div
          key={n->Js.Int.toString}
          className={Styles.shade(
            ~textColor=color
            ->Lab.getContrastColor(~tint=color->Lab.desaturate(~amount=0.7))
            ->Lab.toP3
            ->Lab.p3ToString,
            color->Lab.lighten(n, _)->Lab.toP3->Lab.p3ToString,
          )}
        />
      })
      ->React.array}
    </div>
  </div>
}
