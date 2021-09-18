module Styles = {
  open CssJs
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
  let (saturation, setSaturation) = React.useState(() => 1.)
  let (hue, setHue) = React.useState(() => 0.)
  let (fastHue, setFastHue) = React.useState(() => 0.)
  let color = Lab.hslToP3(#hsl(hue, saturation, lightness))
  let handleSetHue = React.useCallback1(v => {
    setFastHue(_ => v)
    startTransition(() => setHue(_ => v))
  }, [startTransition])

  <div>
    <React.Suspense fallback=React.null>
      <ColorBox color /> <ShadePicker hue saturation lightness setSaturation setLightness />
    </React.Suspense>
    <HueSlider value=fastHue setValue={handleSetHue} />
  </div>
}
