module Styles = {
  open CssJs

  let wrapper = (~size) =>
    style(. [
      position(#relative),
      cursor(#pointer),
      flexShrink(0.),
      maxWidth(#percent(100.)),
      maxHeight(#percent(100.)),
      borderRadius(#px(size)),
      transitionDuration(1500),
      transitionTimingFunction(#cubicBezier(0.2, 0.68, 0., 1.31)),
      hover([
        transform(scale(1.05, 1.05)),
        transitionDuration(200),
        transitionTimingFunction(#cubicBezier(0.2, 0.68, 0., 1.71)),
      ]),
      active([
        transform(scale(1.01, 1.01)),
        transitionDuration(150),
        transitionTimingFunction(#cubicBezier(0.2, 0.68, 0., 1.71)),
      ]),
    ])
  let rotationKeyframes = keyframes(. [
    (0, [transform(#rotate(#deg(0.)))]),
    (100, [transform(#rotate(#deg(360.)))]),
  ])
  let beforeAfter = (~size) => [
    contentRule(#text("")),
    position(#absolute),
    animationName(rotationKeyframes),
    animationDuration(20000),
    animationTimingFunction(#linear),
    animationIterationCount(#infinite),
    borderRadius(#px(size)),
    zIndex(-1),
    width(#percent(100.)),
    height(#percent(100.)),
    transform(#rotate(#deg(90.))),
    unsafe(
      "background",
      "conic-gradient(
      from 90deg,
      lch(75% 90 0),
      lch(75% 90 20),
      lch(75% 90 40),
      lch(75% 90 60),
      lch(75% 90 80),
      lch(75% 90 100),
      lch(75% 90 120),
      lch(75% 90 140),
      lch(75% 90 160),
      lch(75% 90 180),
      lch(75% 90 200),
      lch(75% 90 220),
      lch(75% 90 240),
      lch(75% 90 260),
      lch(75% 90 280),
      lch(75% 90 300),
      lch(75% 90 320),
      lch(75% 90 340),
      lch(75% 90 360)
    )",
    ),
  ]
  let canvas = (~size) =>
    style(. [
      width(#px(size)),
      height(#px(size)),
      maxWidth(#percent(100.)),
      maxHeight(#percent(100.)),
      borderRadius(#px(size)),
      position(#relative),
      before(beforeAfter(~size)),
      unsafe(
        "clipPath",
        "polygon(0% 100%, 100% 100%, 100% 0%, 0% 0%, 0 42%, 20% 42%, 42% 42%, 42% 20%, 57% 20%, 57% 42%, 80% 42%, 80% 57%, 57% 57%, 57% 80%, 42% 80%, 42% 57%, 20% 57%, 20% 42%, 0 42%)",
      ),
    ])
  let blurred = (~size) =>
    style(. [
      position(#absolute),
      top(#px(0)),
      left(#px(0)),
      width(#px(size)),
      height(#px(size)),
      maxWidth(#percent(100.)),
      maxHeight(#percent(100.)),
      borderRadius(#px(size)),
      opacity(0.4),
      unsafe("filter", `blur(${(size / 6)->string_of_int}px)`),
      transitionDuration(1500),
      selector(.
        "*:hover > &",
        [
          opacity(0.7),
          unsafe("filter", `blur(${(size / 7)->string_of_int}px)`),
          transitionDuration(200),
          transitionTimingFunction(#cubicBezier(0.2, 0.68, 0., 1.71)),
        ],
      ),
      selector(.
        "*:active > &",
        [
          unsafe("filter", "blur(30px)"),
          transitionDuration(150),
          transitionTimingFunction(#cubicBezier(0.2, 0.68, 0., 1.71)),
        ],
      ),
      unsafe(
        "clipPath",
        "polygon(-50% 150%, 150% 150%, 150% -50%, -50% -50%, -50% 42%, 20% 42%, 42% 42%, 42% 20%, 57% 20%, 57% 42%, 80% 42%, 80% 57%, 57% 57%, 57% 80%, 42% 80%, 42% 57%, 20% 57%, 20% 42%, -50% 42%)",
      ),
      before(beforeAfter(~size)),
    ])
}

@react.component
let make = (~onPress, ~size=180) => {
  <div role="button" className={Styles.wrapper(~size)} onClick={onPress} tabIndex=0>
    <div className={Styles.canvas(~size)} /> <div className={Styles.blurred(~size)} />
  </div>
}
