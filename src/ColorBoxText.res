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

let rec toString = (color, format) =>
  switch (color, format) {
  | (#lch(l, c, h, _), LCH) => `lch(${l->f} ${c->f} ${h->f})`
  | (#lch(_, _, _, _) as lch, _) => lch->Lab.fromLCH->toString(_, format)
  | (#lab(_, _, _, _) as lab, P3) =>
    lab
    ->Lab.toP3
    ->(
      p3c =>
        switch p3c {
        | #p3(r, g, b, _a) => `p3(${r->f} ${g->f} ${b->f})`
        }
    )

  | (#lab(_, _, _, _) as lab, LCH) => lab->Lab.toLCH->toString(_, format)
  | (#lab(l, a, b, _), LAB) => `lab(${l->f} ${a->f} ${b->f})`
  }
let getLightness = x =>
  switch x {
  | #lch(l, _, _, _)
  | #lab(l, _, _, _) => l
  }

let getFaintTextColor = color => Lab.getTextColor(~level=Lab.A, ~size=Lab.Normal, color)

let getNormalTextColor = color =>
  Lab.getTextColor(~level=Lab.AAAA, ~size=Lab.Large, color->Lab.desaturate(~amount=0.8))

// color->Lab.getContrastColor(~tint=color->Lab.desaturate(~amount=0.8))

module Heading = {
  @react.component
  let make = (~color, ~children, ()) => {
    <span className={Styles.header(~color=color->Lab.toP3->Lab.p3ToString)}> {children} </span>
  }
}

@react.component
let make = (~color) => {
  let textColor = color->getNormalTextColor
  let faintTextColor = color->getFaintTextColor
  <div className={Styles.wrapper(~color=textColor->Lab.toP3->Lab.p3ToString)}>
    <div className={Styles.section}>
      <Heading color=faintTextColor> {"Base"->React.string} </Heading>
      <span> {color->toString(LCH)->React.string} </span>
      <span> {color->toString(P3)->React.string} </span>
    </div>
    <div className={Styles.section}>
      <Heading color=faintTextColor> {"Text"->React.string} </Heading>
      <span> {textColor->toString(LCH)->React.string} </span>
      <span> {textColor->toString(P3)->React.string} </span>
    </div>
    <div className={Styles.section}>
      <Heading color=faintTextColor> {"Faint text"->React.string} </Heading>
      <span> {faintTextColor->toString(LCH)->React.string} </span>
      <span> {faintTextColor->toString(P3)->React.string} </span>
    </div>
  </div>
}
