module Styles = {
  open CssJs

  let wrapper = (~color) =>
    style(. [
      display(#flex),
      justifyContent(#spaceBetween),
      alignItems(#center),
      alignContent(#stretch),
      flexDirection(#column),
      minWidth(#px(290)),
      unsafe("backgroundColor", color),
      width(#percent(100.)),
      padding(#px(40)),
    ])

  let section = style(. [display(#flex), flexDirection(#column), maxWidth(#px(290))])

  let shade = color =>
    style(. [
      display(#flex),
      fontWeight(#bold),
      flexGrow(0.),
      alignItems(#center),
      justifyContent(#center),
      width(#px(40)),
      height(#px(40)),
      unsafe("backgroundColor", color),
    ])

  let shades = style(. [
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
let posShades = [5, 10, 15, 25, 35, 45]->Belt.Array.reverse
let negShades = [-45, -35, -25, -15, -10, -5]->Belt.Array.reverse

@react.component
let make = (~color, ~onDelete, ~onEdit as _) => {
  let labColor = color->Lab.toLab
  Lab.getTextColor(~level=Lab.AA, ~size=Lab.Large, color)->Lab.toP3->Lab.p3ToString->Js.log2("c")
  <div
    className={Styles.wrapper(~color=color->Obj.magic->Lab.toP3->Lab.p3ToString)}
    onClick={_ => onDelete()}>
    <div className=Styles.section>
      <div className=Styles.shades key={labColor->Lab.toP3->Lab.p3ToString}>
        {posShades
        ->Belt.Array.map(n => {
          <div
            key={n->Js.Int.toString}
            className={Styles.shade(color->Lab.lighten(n, _)->Lab.toP3->Lab.p3ToString)}
          />
        })
        ->React.array}
      </div>
      <ColorBoxText color />
    </div>
    <div className=Styles.shades key={labColor->Lab.toP3->Lab.p3ToString}>
      {negShades
      ->Belt.Array.map(n => {
        <div
          key={n->Js.Int.toString}
          className={Styles.shade(color->Lab.lighten(n, _)->Lab.toP3->Lab.p3ToString)}
        />
      })
      ->React.array}
    </div>
  </div>
}
