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
  let (_isPending, startTransition) = ReactExperimental.useTransition({timeoutMs: 2000})
  let (lightness, setLightness) = React.useState(() => 50.)
  let (chroma, setChroma) = React.useState(() => 66.)
  let (hue, setHue) = React.useState(() => Js.Math._PI)
  let (fastHue, setFastHue) = React.useState(() => Js.Math._PI)
  let color = #lch(lightness, chroma, hue, 1.)
  let handleSetHue = React.useCallback1(v => {
    setFastHue(_ => v)
    startTransition(() => setHue(_ => v))
  }, [startTransition])
  <div className={Styles.wrapper}>
    <React.Suspense fallback=React.null>
      <ColorBox color /> <ShadePicker hue chroma lightness setChroma setLightness />
    </React.Suspense>
    <HueSlider value=fastHue setValue={handleSetHue} />
  </div>
}
