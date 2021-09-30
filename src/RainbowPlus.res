let size = 180.
let sizeInt = size->int_of_float

module Styles = {
  open CssJs

  let wrapper = style(. [
    position(#relative),
    cursor(#pointer),
    flexShrink(0.),
    transitionDuration(1500),
    borderRadius(#px(sizeInt)),
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
  let beforeAfter = [
    contentRule(#text("")),
    position(#absolute),
    animationName(rotationKeyframes),
    animationDuration(20000),
    animationTimingFunction(#linear),
    animationIterationCount(#infinite),
    borderRadius(#px(sizeInt)),
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
  let canvas = style(. [
    width(#px(sizeInt)),
    height(#px(sizeInt)),
    borderRadius(#px(sizeInt)),
    position(#relative),
    before(beforeAfter),
    unsafe(
      "clipPath",
      "polygon(0% 100%, 100% 100%, 100% 0%, 0% 0%, 0 42%, 20% 42%, 42% 42%, 42% 20%, 57% 20%, 57% 42%, 80% 42%, 80% 57%, 57% 57%, 57% 80%, 42% 80%, 42% 57%, 20% 57%, 20% 42%, 0 42%)",
    ),
  ])
  let blurred = style(. [
    position(#absolute),
    top(#px(0)),
    left(#px(0)),
    width(#px(sizeInt)),
    height(#px(sizeInt)),
    borderRadius(#px(sizeInt)),
    opacity(0.4),
    unsafe("filter", "blur(30px)"),
    transitionDuration(1500),
    selector(.
      "*:hover > &",
      [
        opacity(0.7),
        unsafe("filter", "blur(25px)"),
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
    before(beforeAfter),
  ])
}

@react.component
let make = () => {
  <div>
    <div role="button" className=Styles.wrapper>
      <div className=Styles.canvas width="50" height="50" />
      <div className=Styles.blurred width="50" height="50" />
    </div>
  </div>
}
