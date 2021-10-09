module Styles = {
  open CssJs
  let wrapper = style(. [
    position(#relative),
    display(#flex),
    top(#px(0)),
    bottom(#px(80)),
    width(#vw(100.)),
    height(#percent(100.)),
    display(#flex),
    flexDirection(#row),
    alignItems(#stretch),
    justifyContent(#stretch),
  ])
}

@react.component
let make = (~colors, ~setColors) => {
  <div className={Styles.wrapper}>
    {colors
    ->Belt.Array.length
    ->(
      l =>
        switch l {
        | 0 => React.null
        | _ =>
          colors
          ->Belt.Array.map(color => {
            let key = color->Lab.getKey
            <ColorBox
              color={color->Lab.toLCH}
              key
              onDelete={() =>
                setColors(oldColors =>
                  oldColors->Belt.Array.keep(oldColor => oldColor->Lab.getKey !== key)
                )}
              onEdit={newColor =>
                setColors(oldColors =>
                  oldColors->Belt.Array.map(oldColor =>
                    oldColor->Lab.getKey === key ? newColor : oldColor
                  )
                )}
            />
          })
          ->React.array
        }
    )}
  </div>
}
