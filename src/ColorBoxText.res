module Styles = {
  open CssJs

  let header = (~color) => style(. [unsafe("color", color)])

  let wrapper = (~color) =>
    style(. [
      display(#flex),
      justifyContent(#flexStart),
      alignItems(#flexStart),
      alignContent(#flexStart),
      flexDirection(#column),
      // flexGrow(1.),
      width(#percent(100.)),
      unsafe("color", color),
    ])

  let section = style(. [
    display(#flex),
    justifyContent(#flexStart),
    alignItems(#flexStart),
    alignContent(#flexStart),
    flexDirection(#column),
    paddingTop(#px(20)),
    fontWeight(#semiBold),
    fontSize(#px(16)),
    lineHeight(#px(24)),
  ])
}

type colorFormat = P3 | LCH | LAB
let f = num => (num *. 100.)->Js.Math.round->(a => a /. 100.)->Js.Float.toString

let getLightness = x =>
  switch x {
  | #lch(l, _, _, _)
  | #lab(l, _, _, _) => l
  }

let getAATextColor = color => Lab.getTextColor(~level=Lab.AA, ~size=Lab.Large, color)

let getAAATextColor = color =>
  Lab.getTextColor(~level=Lab.AAA, ~size=Lab.Large, color->Lab.desaturate(~amount=0.9))

let getAAAATextColor = color =>
  Lab.getTextColor(~level=Lab.AAAA, ~size=Lab.Large, color->Lab.desaturate(~amount=0.8))

// color->Lab.getContrastColor(~tint=color->Lab.desaturate(~amount=0.8))

module Heading = {
  @react.component
  let make = (~color, ~children, ()) => {
    <span className={Styles.header(~color=color->Lab.toString(P3))}> {children} </span>
  }
}

@react.component
let make = (~color) => {
  let aaaaTextColor = color->getAAAATextColor
  let aaaTextColor = color->getAAATextColor
  let aaTextColor = color->getAATextColor
  <div className={Styles.wrapper(~color=aaaaTextColor->Lab.toString(P3))}>
    <div className={Styles.section}>
      <Heading color=aaTextColor> {"Base"->React.string} </Heading>
      <span> {color->Lab.toLCH->Lab.toString(LCH)->React.string} </span>
    </div>
    <div className={Styles.section}>
      <Heading color=aaTextColor> {"AAAA Text"->React.string} </Heading>
      <span> {aaaaTextColor->Lab.toString(LCH)->React.string} </span>
    </div>
    <div className={Styles.section}>
      <Heading color=aaTextColor> {"AAA Text"->React.string} </Heading>
      <span> {aaaTextColor->Lab.toString(LCH)->React.string} </span>
    </div>
    <div className={Styles.section}>
      <Heading color=aaTextColor> {"AA text"->React.string} </Heading>
      <span> {aaTextColor->Lab.toString(LCH)->React.string} </span>
    </div>
  </div>
}
