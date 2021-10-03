module Styles = {
  open CssJs
  let flex = style(. [display(#flex), flexDirection(#row), width(px(500))])
  let wrapper = style(. [
    display(#flex),
    flexDirection(#column),
    width(#vw(100.)),
    maxWidth(px(500)),
    alignItems(#center),
    justifyContent(#center),
  ])

  let button = (~textColor, ~highlightColor, color) =>
    style(. [
      unsafe("appearance", "none"),
      borderWidth(#px(0)),
      display(#flex),
      fontSize(#px(28)),
      fontWeight(#bold),
      alignItems(#center),
      justifyContent(#center),
      width(#percent(500. /. 9.)),
      height(#px(50)),
      unsafe("backgroundColor", color),
      unsafe("color", textColor),
      cursor(#pointer),
      width(#percent(100.)),
      hover([unsafe("backgroundColor", highlightColor)]),
    ])
}

@react.component
let make = (~onDone, ~initialColor=None) => {
  let (startL, startC, startH) = switch initialColor {
  | Some(c) =>
    switch c {
    | #lch(l, c, h, _a) => (l, c, h)
    }
  | None => (50., 66., Js.Math._PI)
  }

  let (_isPending, startTransition) = ReactExperimental.useTransition({timeoutMs: 2000})
  let (lightness, setLightness) = React.useState(() => startL)
  let (chroma, setChroma) = React.useState(() => startC)
  let (hue, setHue) = React.useState(() => startH)
  let (fastHue, setFastHue) = React.useState(() => startH)
  let color = #lch(lightness, chroma, hue, 1.)
  let handleSetHue = React.useCallback1(v => {
    setFastHue(_ => v)
    startTransition(() => setHue(_ => v))
  }, [startTransition])
  <div className={Styles.wrapper}>
    <HueSlider value=fastHue setValue={handleSetHue} />
    <React.Suspense fallback=React.null>
      // <ColorBox color />
      <ShadePicker hue chroma lightness setChroma setLightness />
      <button
        className={Styles.button(
          ~textColor=color
          ->Lab.getContrastColor(~tint=color->Lab.desaturate(~amount=0.7))
          ->Lab.toP3
          ->Lab.p3ToString,
          ~highlightColor=color->Lab.lighten(5, _)->Lab.toP3->Lab.p3ToString,
          color->Lab.toP3->Lab.p3ToString,
        )}
        onClick={_ => onDone(color)}>
        {j`✓`->React.string}
      </button>
    </React.Suspense>
  </div>
}
