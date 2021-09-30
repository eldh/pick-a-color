module Styles = {
  open CssJs
  let flex = style(. [display(#flex), flexDirection(#row), width(px(500))])
  let wrapper = style(. [
    display(#flex),
    flexDirection(#column),
    width(#vw(100.)),
    alignItems(#center),
    justifyContent(#center),
    unsafe("gap", "60px"),
  ])
  let text = style(. [fontSize(#px(30)), fontWeight(#bold), color(#hex("333"))])
}

@react.component
let make = () => {
  <div className={Styles.wrapper}>
    <div className={Styles.text}> {"We all need some color in our lives."->React.string} </div>
    <RainbowPlus />
    // <ColorPicker />
  </div>
}
