module Styles = {
  open CssJs
  let flex = style(. [display(#flex), flexDirection(#row), width(px(500))])

  let test = bg =>
    style(. [
      position(#relative),
      width(px(50)),
      height(px(50)),
      unsafe("background", bg),
      borderRadius(#px(2)),
      boxShadow(Shadow.box(~y=px(1), ~blur=px(2), rgba(0, 0, 0, #num(0.5)))),
    ])
}

@react.component
let make = () => {
  let (_isPending, startTransition) = ReactExperimental.useTransition({timeoutMs: 2000})
  let (lightness, setLightness) = React.useState(() => 1.)
  let (chroma, setChroma) = React.useState(() => 1.)
  let (hue, setHue) = React.useState(() => 0.)
  let (fastHue, setFastHue) = React.useState(() => 0.)
  let color = #lch(lightness, chroma, hue, 1.)
  Js.log(color)
  let handleSetHue = React.useCallback1(v => {
    setFastHue(_ => v)
    startTransition(() => setHue(_ => v))
  }, [startTransition])

  <div>
    <React.Suspense fallback=React.null>
      <ColorBox color /> <LabShadePicker hue chroma lightness setChroma setLightness />
    </React.Suspense>
    <LabHueSlider value=fastHue setValue={handleSetHue} />
  </div>
}
