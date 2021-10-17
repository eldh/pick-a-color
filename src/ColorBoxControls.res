module Styles = {
  open CssJs

  let wrapper = (~color) =>
    style(. [
      display(#flex),
      justifyContent(#center),
      alignItems(#center),
      alignContent(#center),
      unsafe("color", color),
      flexDirection(#row),
      minWidth(#px(290)),
      width(#percent(100.)),
      paddingBottom(#px(30)),
      unsafe("gap", "10px"),
    ])
  let pickerWrapper = style(. [
    position(#fixed),
    display(#flex),
    top(#px(0)),
    left(#px(0)),
    flexDirection(#column),
    width(#vw(100.)),
    height(#vh(100.)),
    alignItems(#center),
    justifyContent(#center),
    unsafe("backdropFilter", "blur(25px)"),
    zIndex(2),
  ])
  let button = (~color) =>
    style(. [
      display(#flex),
      alignItems(#center),
      justifyContent(#center),
      padding(#px(5)),
      width(#px(27)),
      height(#px(27)),
      borderRadius(#px(20)),
      borderStyle(#solid),
      borderWidth(#px(2)),
      unsafe("borderColor", color->Lab.toString(P3)),
      cursor(#pointer),
      transitionDuration(750),
      opacity(0.5),
      unsafe("backgroundColor", color->Lab.setAlpha(0., _)->Lab.toString(P3)),
      hover([
        transitionDuration(100),
        opacity(0.7),
        unsafe("backgroundColor", color->Lab.setAlpha(0.1, _)->Lab.toString(P3)),
      ]),
    ])
  let flex = style(. [display(#flex), flexDirection(#columnReverse), flexGrow(1.)])
}

@react.component
let make = (~color, ~onDelete, ~onEdit, ~onCopy) => {
  let lchColor = color->Lab.toLCH
  let (editing, setEditing) = React.useState(() => false)
  <>
    {editing
      ? <div className={Styles.pickerWrapper}>
          <ColorPicker
            initialColor=Some(lchColor)
            onDone={c => {
              onEdit(c)
              setEditing(_ => false)
            }}
          />
        </div>
      : React.null}
    <div className={Styles.wrapper(~color=color->ColorBoxText.getAAAATextColor->Lab.toString(P3))}>
      <div
        className={Styles.button(~color=color->ColorBoxText.getAAAATextColor)}
        role="button"
        tabIndex={0}
        onClick={_ => onCopy()}>
        <CopyIcon />
      </div>
      <div
        className={Styles.button(~color=color->ColorBoxText.getAAAATextColor)}
        role="button"
        tabIndex={0}
        onClick={_ => setEditing(_ => true)}>
        <EditIcon />
      </div>
      <div
        className={Styles.button(~color=color->ColorBoxText.getAAAATextColor)}
        role="button"
        tabIndex={0}
        onClick={_ => onDelete()}>
        <CloseIcon />
      </div>
    </div>
  </>
}
