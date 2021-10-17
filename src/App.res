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
    zIndex(1),
  ])
  let boxesWrapper = style(. [
    display(#flex),
    flexDirection(#column),
    position(#absolute),
    width(#vw(100.)),
    top(#px(0)),
    marginTop(#px(0)),
    unsafe("height", "calc(100vh - 80px)"),
    alignItems(#stretch),
    justifyContent(#stretch),
    overflow(#auto),
  ])
  let tabBarPickerWrapper = style(. [
    position(#fixed),
    display(#flex),
    flexDirection(#column),
    width(#vw(100.)),
    height(#vh(100.)),
    alignItems(#center),
    justifyContent(#center),
    unsafe("backdropFilter", "blur(25px)"),
    zIndex(2),
  ])
  let tabBarPicker = style(. [
    position(#fixed),
    display(#flex),
    flexDirection(#row),
    width(#percent(100.)),
    height(#px(80)),
    bottom(#px(0)),
    flexGrow(0.),
    left(#px(0)),
    alignItems(#center),
    justifyContent(#center),
    backgroundColor(#hex("000")),
    zIndex(1),
    alignSelf(#flexEnd),
  ])
  let text = style(. [fontSize(#px(30)), fontWeight(#bold), color(#hex("555"))])
}

module EmptyPicker = {
  @react.component
  let make = (~colors, ~setColors) => {
    let (showPicker, setShowPicker) = React.useState(() => false)
    <div className={Styles.wrapper}>
      {showPicker
        ? <ColorPicker
            initialColor={colors->Belt.Array.get(0)}
            onDone={c => {
              setShowPicker(_ => false)
              setColors(prev => [c]->Belt.Array.concat(prev))
            }}
          />
        : <>
            <div className={Styles.text}>
              {"We all need some color in our lives."->React.string}
            </div>
            <RainbowPlus onPress={_ => setShowPicker(_ => true)} />
          </>}
    </div>
  }
}
module TabBarPicker = {
  @react.component
  let make = (~colors, ~setColors) => {
    let (showPicker, setShowPicker) = React.useState(() => false)
    <>
      {showPicker
        ? <div className={Styles.tabBarPickerWrapper}>
            <ColorPicker
              initialColor={colors->Belt.Array.get(0)}
              onDone={c => {
                setShowPicker(_ => false)
                setColors(prev => [c]->Belt.Array.concat(prev))
              }}
            />
          </div>
        : React.null}
      <div className=Styles.tabBarPicker>
        <RainbowPlus onPress={_ => setShowPicker(_ => true)} size=50 />
      </div>
    </>
  }
}

let toHash = color => {
  color->Lab.toLCH->Lab.toString(URL)
}

let fromHash = str => {
  let (l, c, h, a) = Js.String.match_(%re("/([\d+.\d+]+)/g"), str)->Obj.magic
  #lch(
    l->Js.Float.fromString,
    c->Js.Float.fromString,
    h->Js.Float.fromString,
    a->Js.Float.fromString,
  )
}

let setHash = str => {
  RescriptReactRouter.push("#" ++ str)
}
let useColorFromHash = () => {
  let url = RescriptReactRouter.useUrl()
  switch url.hash {
  | "" => None
  | a => Some(Js.String.split(";", a)->Belt.Array.map(fromHash))
  }
}

@react.component
let make = () => {
  let initialColor = useColorFromHash()
  let (colors, setColors) = React.useState(() => initialColor->Belt.Option.getWithDefault([]))
  let urlHash = colors->Belt.Array.joinWith(";", toHash)
  React.useEffect1(() => {
    urlHash->setHash
    None
  }, [urlHash])
  <>
    {colors->Belt.Array.length === 0
      ? <EmptyPicker colors setColors />
      : <>
          <div className=Styles.boxesWrapper> <ColorBoxes colors setColors /> </div>
          <TabBarPicker colors setColors />
        </>}
  </>
}
