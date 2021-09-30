module Styles = {
  open CssJs
  let flex = style(. [display(#flex), flexDirection(#row), width(px(500))])
  let wrapper = style(. [
    display(#flex),
    flexDirection(#column),
    width(#vw(100.)),
    alignItems(#center),
    justifyContent(#center),
  ])
}

@react.component
let make = () => {
  <div className={Styles.wrapper}> <RainbowPlus /> <ColorPicker /> </div>
}
