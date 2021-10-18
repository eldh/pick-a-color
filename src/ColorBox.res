let copyTopClipboard: string => unit = %raw(`
  function(str) {
    navigator.clipboard.writeText(str)
  }
`)

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

  let shade = (~selected, color) =>
    style(. [
      display(#flex),
      fontWeight(#bold),
      flexGrow(0.),
      alignItems(#center),
      justifyContent(#center),
      width(#px(40)),
      height(#px(40)),
      cursor(#pointer),
      position(#relative),
      borderRadius(#px(25)),
      unsafe("backgroundColor", color->Lab.toString(P3)),
      transitionDuration(750),
      hover([transitionDuration(100), opacity(0.6)]),
      before([
        contentRule(#text(" ")),
        borderRadius(#px(25)),
        position(#absolute),
        top(#px(-4)),
        left(#px(-4)),
        width(#px(45)),
        height(#px(45)),
        borderWidth(#px(2)),
        borderStyle(#solid),
        unsafe(
          "borderColor",
          selected
            ? color->Lab.getTextColor(~level=Lab.A, ~size=Lab.Large)->Lab.toString(P3)
            : "transparent",
        ),
        zIndex(1),
      ]),
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

let posShades = [5, 10, 15, 25, 35, 45]->Belt.Array.reverse
let negShades = [-45, -35, -25, -15, -10, -5]->Belt.Array.reverse
let shades = Belt.Array.concatMany([[0], posShades, negShades])
type colorVariants<'a> = {
  base: 'a,
  aa: 'a,
  aaa: 'a,
  aaaa: 'a,
}
@react.component
let make = (~color as baseColor, ~onDelete, ~onEdit) => {
  let (selectedShade, setSelectedShade) = React.useState(() => None)

  let onCopy = () => {
    let stringsForColor = c => {
      [
        c->Lab.toString(P3),
        c->Lab.toLCH->Lab.toString(LCH),
        c->Lab.toString(HEX),
      ]->Belt.Array.joinWith(" / ", a => a)
    }
    let variantsForColor = c => {
      base: c,
      aa: c->ColorBoxText.getAATextColor,
      aaa: c->ColorBoxText.getAAATextColor,
      aaaa: c->ColorBoxText.getAAAATextColor,
    }
    let negShadesForColor = c => negShades->Belt.Array.map(n => Lab.lighten(n, c))
    let posShadesForColor = c => posShades->Belt.Array.map(n => Lab.lighten(n, c))
    let negVariants = baseColor->negShadesForColor->Belt.Array.map(variantsForColor)
    let posVariants = baseColor->posShadesForColor->Belt.Array.map(variantsForColor)
    let baseVariants = baseColor->variantsForColor

    let stringForVariants = variants =>
      `Base: ${stringsForColor(variants.base)}
AA text: ${stringsForColor(variants.aa)}
AAA text: ${stringsForColor(variants.aaa)}
AAAA text: ${stringsForColor(variants.aaaa)}
    `
    let copyStr = `# Original color:
    
${baseVariants->stringForVariants}
# Variants:

${negVariants
      ->Belt.Array.map(stringForVariants)
      ->Belt.Array.mapWithIndex((i, c) => (Belt.Array.getUnsafe(negShades, i), c))
      ->Belt.Array.joinWith("\n", ((n, c)) => "## Darker " ++ n->string_of_int ++ ":\n" ++ c)}
${posVariants
      ->Belt.Array.map(stringForVariants)
      ->Belt.Array.mapWithIndex((i, c) => (Belt.Array.getUnsafe(posShades, i), c))
      ->Belt.Array.reverse
      ->Belt.Array.joinWith("\n", ((n, c)) => "## Lighter " ++ n->string_of_int ++ ":\n" ++ c)}`
    Js.log(copyStr)
    copyTopClipboard(copyStr)
  }

  let color =
    selectedShade->Belt.Option.mapWithDefault(baseColor, v => baseColor->Lab.lighten(v, _))
  let renderShade = n => {
    let shadeColor = baseColor->Lab.lighten(n, _)
    let selected = selectedShade->Belt.Option.getWithDefault(0) === n
    <div
      role="button"
      tabIndex={0}
      onClick={e => {
        e->ReactEvent.Mouse.preventDefault
        e->ReactEvent.Mouse.stopPropagation
        setSelectedShade(_ => {
          selected ? None : Some(n)
        })
      }}
      key={n->Js.Int.toString}
      className={Styles.shade(~selected, shadeColor)}
    />
  }
  <div
    className={Styles.wrapper(~color=color->Lab.toString(P3))}
    role="button"
    tabIndex={0}
    onClick={e => {
      e->ReactEvent.Mouse.preventDefault
      e->ReactEvent.Mouse.stopPropagation
      setSelectedShade(_ => None)
    }}>
    <div className=Styles.section>
      <div className=Styles.shades key={baseColor->Lab.toString(P3)}>
        {posShades->Belt.Array.map(renderShade)->React.array}
      </div>
      <ColorBoxText color />
    </div>
    <div className=Styles.section>
      <ColorBoxControls color=baseColor onEdit onDelete onCopy />
      <div className=Styles.shades key={baseColor->Lab.toString(P3)}>
        {negShades->Belt.Array.map(renderShade)->React.array}
      </div>
    </div>
  </div>
}
