exception InvalidValue(string)

/*
 * L* [0..100]
 * a [-100..100]
 * b [-100..100]
 */

type t = [#lab(float, float, float, float)]

type a11yLevel =
  | A
  | AA
  | AAA
  | AAAA

type a11yTextSize =
  | Normal
  | Large

let toPrecision = %raw(`
  function(a, b) {
    return Number(b.toPrecision(a))
  }
`)

let toFixed = (i0, f) => {
  let i = i0 |> float_of_int
  if f < 1. {
    let multiplier = 10. ** i
    float_of_int(int_of_float(multiplier *. f +. 0.5)) /. multiplier
  } else {
    toPrecision(i0, f)
  }
}

let clamp = (minVal, maxVal, v) =>
  if v < minVal {
    minVal
  } else if v > maxVal {
    maxVal
  } else {
    v
  }

let multiplyMatrix = (((x1, x2, x3), (y1, y2, y3), (z1, z2, z3)), (a, b, c)) => (
  x1 *. a +. x2 *. b +. x3 *. c,
  y1 *. a +. y2 *. b +. y3 *. c,
  z1 *. a +. z2 *. b +. z3 *. c,
)

let mapTriple = (fn, (a, b, c)) => (fn(a), fn(b), fn(c))
let intOfFloat = f => f +. 0.5 |> int_of_float

let rgbClamp = clamp(0, 255)
let p3Clamp = a => clamp(0., 1.0, a) |> toPrecision(4)
let toInt = f => f +. 0.5 |> int_of_float

let rgbGamma = r => r <= 0.0031308 ? 12.92 *. r : 1.055 *. r ** (1. /. 2.4) -. 0.055
let srgbGamma = r => 255. *. rgbGamma(r)

let rgbLinear = r => {
  let lab2 = r
  if lab2 <= 0.04045 {
    lab2 /. 12.92
  } else {
    ((lab2 +. 0.055) /. 1.055) ** 2.4
  }
}

let srgbLinear = r => rgbLinear(r /. 255.)

// Convert from linear sRGB to CIE XYZ
let linearRgbToXyz = multiplyMatrix((
  (0.4124564, 0.3575761, 0.1804375),
  (0.2126729, 0.7151522, 0.0721750),
  (0.0193339, 0.1191920, 0.9503041),
))

let linearP3ToXyz = multiplyMatrix((
  (0.4865709486482162, 0.26566769316909306, 0.1982172852343625),
  (0.2289745640697488, 0.6917385218365064, 0.079286914093745),
  (0.0000000000000000, 0.04511338185890264, 1.043944368900976),
))

// Convert from a D65 whitepoint (used by sRGB) to the D50 whitepoint used in Lab, with the Bradford transform [Bradford-CAT]
let d65ToD50 = multiplyMatrix((
  (1.0478112, 0.0228866, -0.0501270),
  (0.0295424, 0.9904844, -0.0170491),
  (-0.0092345, 0.0150436, 0.7521316),
))

let e = 216. /. 24389. // 6^3/29^3
let k = 24389. /. 27. // 29^3/3^3
let d50White = (0.96422, 1., 0.82521) // D50 reference white
let xyzToLab = ((x1, y1, z1)) => {
  // Assuming XYZ is relative to D50, convert to CIE Lab
  // from CIE standard, which now defines these as a rational fraction
  let (wX, wY, wZ) = d50White

  // compute xyz, which is XYZ scaled relative to reference white
  // let xyz = XYZ.map((value, i) => value /. white[i]);
  let xyz = (x1 /. wX, y1 /. wY, z1 /. wZ)

  // now compute f
  let (f0, f1, f2) = mapTriple(v => v > e ? v ** (1. /. 3.) : (k *. v +. 16.) /. 116., xyz)

  (116. *. f1 -. 16., 500. *. (f0 -. f1), 200. *. (f1 -. f2)) // L // a // b
}

let labToXyz = ((l, a, b)) => {
  // Convert Lab to D50-adapted XYZ
  // http://www.brucelindbloom.com/index.html?Eqn_RGB_XYZ_Matrix.html

  // compute f, starting with the luminance-related term
  let f1 = (l +. 16.) /. 116.
  let f0 = a /. 500. +. f1
  let f2 = f1 -. b /. 200.

  // compute xyz
  let x = f0 ** 3. > e ? f0 ** 3. : (116. *. f0 -. 16.) /. k
  let y = l > k *. e ? ((l +. 16.) /. 116.) ** 3. : l /. k
  let z = f2 ** 3. > e ? f2 ** 3. : (116. *. f2 -. 16.) /. k
  let (wX, wY, wZ) = d50White
  // Compute XYZ by scaling xyz by reference white
  (x *. wX, y *. wY, z *. wZ)
}

let d50ToD65 = multiplyMatrix((
  (0.9555766, -0.0230393, 0.0631636),
  (-0.0282895, 1.0099416, 0.0210077),
  (0.0122982, -0.0204830, 1.3299098),
))

let xyzToRGB = multiplyMatrix((
  (3.2404542, -1.5371385, -0.4985314),
  (-0.9692660, 1.8760108, 0.0415560),
  (0.0556434, -0.2040259, 1.0572252),
))

let xyzToP3 = multiplyMatrix((
  (2.493496911941425, -0.9313836179191239, -0.40271078445071684),
  (-0.8294889695615747, 1.7626640603183463, 0.023624685841943577),
  (0.03584583024378447, -0.07617238926804182, 0.9568845240076872),
))

let rec fromRGB = x =>
  switch x {
  | #rgb(r, g, b) => #rgba(r, g, b, 1.) |> fromRGB
  | #rgba(r, g, b, alpha) =>
    (r, g, b)
    |> mapTriple(float_of_int)
    |> mapTriple(srgbLinear)
    |> linearRgbToXyz
    |> d65ToD50
    |> xyzToLab
    |> mapTriple(toFixed(4))
    |> (((l, a, b)) => #lab(l, a, b, alpha))
  }

let toRGB = x =>
  switch x {
  | #lab(l, a, b, alpha) =>
    (l, a, b)
    |> labToXyz
    |> d50ToD65
    |> xyzToRGB
    |> mapTriple(srgbGamma)
    |> mapTriple(intOfFloat)
    |> mapTriple(rgbClamp)
    |> (((r, g, b)) => #rgba(r, g, b, alpha))
  }

let fromLCH = x =>
  switch x {
  | #lch(l, c, h, alpha: float) => #lab(l, c *. Js.Math.cos(h), c *. Js.Math.sin(h), alpha)
  }
let toLCH = x =>
  switch x {
  | #lch(_, _, _, _) as lch => lch
  | #lab(l, a, b, alpha: float) =>
    #lch(
      l,
      Js.Math.sqrt(a *. a +. b *. b),
      Js.Math.atan(b /. a) >= 0. ? Js.Math.atan(b /. a) : Js.Math.atan(b /. a) +. Js.Math._PI *. 2.,
      alpha,
    )
  }

let fromP3 = x =>
  switch x {
  | #p3(r, g, b, alpha: float) =>
    (r, g, b)
    |> mapTriple(rgbLinear)
    |> linearP3ToXyz
    |> d65ToD50
    |> xyzToLab
    |> mapTriple(toFixed(4))
    |> (((l, a, b)) => #lab(l, a, b, alpha))
  }

let toLab = x =>
  switch x {
  | #lab(_, _, _, _) as lab => lab
  | #lch(_, _, _, _) as lch => fromLCH(lch)
  | #rgb(_, _, _) as rgb => fromRGB(rgb)
  | #p3(_, _, _, _) as p3 => fromP3(p3)
  | #rgba(_, _, _, _) as rgba => fromRGB(rgba)
  | #transparent => #lab(0., 0., 0., 0.)
  }

let rec toP3 = x =>
  switch x {
  | #lch(_, _, _, _) as lch => lch->toLab->toP3
  | #lab(l, a, b, alpha) =>
    (l, a, b)
    |> labToXyz
    |> d50ToD65
    |> xyzToP3
    |> mapTriple(rgbGamma)
    |> mapTriple(p3Clamp)
    |> mapTriple(toFixed(3))
    |> (((r, g, b)) => #p3(r, g, b, alpha))
  }

let rec toCss = x =>
  switch x {
  | #lab(_l, _a, _b, alpha) as lab =>
    switch alpha {
    | 0. => #transparent
    | _ => toRGB(lab)
    }
  | #lch(_, _, _, _) as lch => lch->toCss
  }
type colorFormat = P3 | LCH | LAB | URL | HEX
let f = num => (num *. 100.)->Js.Math.round->(a => a /. 100.)->Js.Float.toString

let rec toString = (color, format) =>
  switch (color, format) {
  | (#lch(l, c, h, a), LCH) =>
    `lch(${l->f}% ${c->f} ${(h *. 360. /. Js.Math._PI)->f}${a !== 1. ? " / " ++ a->f : ""})`
  | (#lch(l, c, h, a), URL) => `${l->f},${c->f},${h->f},${a->f}`
  | (#lch(l, c, h, a) as lch, HEX) =>
    lch
    ->fromLCH
    ->toRGB
    ->(
      c =>
        switch c {
        | #rgba(r, g, b, a) =>
          "rgba(" ++
          r->Belt.Int.toString ++
          " " ++
          g->Belt.Int.toString ++
          " " ++
          b->Belt.Int.toString ++
          (a === 1. ? "" : " / " ++ a->Belt.Float.toString) ++ ")"
        }
    )

  | (#lch(_, _, _, _) as lch, _) => lch->fromLCH->toString(_, format)
  | (#lab(_, _, _, _) as c, P3) =>
    c
    ->toP3
    ->(
      v => {
        switch v {
        | #p3(r, g, b, a) =>
          "color(display-p3 " ++
          r->Belt.Float.toString ++
          " " ++
          g->Belt.Float.toString ++
          " " ++
          b->Belt.Float.toString ++
          (a === 1. ? "" : " / " ++ a->Belt.Float.toString) ++ ")"
        }
      }
    )

  | (#lab(_, _, _, _) as lab, URL)
  | (#lab(_, _, _, _) as lab, HEX)
  | (#lab(_, _, _, _) as lab, LCH) =>
    lab->toLCH->toString(format)
  | (#lab(l, a, b, _), LAB) => `L: ${l->f} A: ${a->f} B: ${b->f}`
  }

// let fromURL = string => {
//   #lch(l, c, h, a)
// }

let getKey = x =>
  switch x {
  | #lch(l, c, h, a) =>
    "lch" ++
    l->Belt.Float.toString ++
    c->Belt.Float.toString ++
    h->Belt.Float.toString ++
    a->Belt.Float.toString
  }

let rgbToString = rgba => {
  switch rgba {
  | #rgba(r, g, b, a) =>
    "rgba(" ++
    r->Belt.Int.toString ++
    ", " ++
    g->Belt.Int.toString ++
    ", " ++
    b->Belt.Int.toString ++
    ", " ++
    a->Belt.Float.toString ++ ")"
  }
}

let lightness = (v, x) =>
  switch x {
  | #lab(_l, a, b, alpha) => #lab(clamp(0., 100., v), a, b, alpha)
  }

let lighten = (factor, x) =>
  switch x {
  | #lab(l, a, b, alpha) => #lab(clamp(0., 100., l +. (factor |> float_of_int)), a, b, alpha)
  | #lch(l, c, h, alpha) => #lch(clamp(0., 100., l +. (factor |> float_of_int)), c, h, alpha)
  }

let setAlpha = (v, x) =>
  switch x {
  | #lab(l, a, b, _) => #lab(l, a, b, v)
  | #lch(l, c, h, _) => #lch(l, c, h, v)
  }

let darken = (factor, c) => c |> lighten(factor * -1)

let rotate = (~deg=Js.Math._PI, color) =>
  switch color {
  | #lch(l, c, h, alpha) =>
    #lch(l, c, h +. deg > 2. *. Js.Math._PI ? h +. deg -. 2. *. Js.Math._PI : h +. deg, alpha)
  | #lab(l, a, b, alpha) =>
    #lab(
      l,
      a *. Js.Math.cos(deg) -. b *. Js.Math.sin(deg),
      a *. Js.Math.sin(deg) +. b *. Js.Math.cos(deg),
      alpha,
    )
  }
let getTuple = x =>
  switch x {
  | #lab(l, a, b, al) => (l, a, b, al)
  }

let mix = (f, lab1, lab2) => {
  let (l1, a1, b1, alpha1) = lab1 |> getTuple
  let (l2, a2, b2, alpha2) = lab2 |> getTuple
  let (x1, y1, z1) = (l1, a1, b1) |> labToXyz
  let (x2, y2, z2) = (l2, a2, b2) |> labToXyz
  (x1 +. f *. (x2 -. x1), y1 +. f *. (y2 -. y1), z1 +. f *. (z2 -. z1))
  |> xyzToLab
  |> (((l, a, b)) => #lab(l, a, b, (alpha1 +. alpha2) /. 2.))
}

let luminance_x = x => {
  let x1 = (x |> float_of_int) /. 255.
  x1 <= 0.03928 ? x1 /. 12.92 : ((x1 +. 0.055) /. 1.055) ** 2.4
}

let luminance = x =>
  switch x {
  | #lab(l: float, _, _, _)
  | #lch(l: float, _, _, _) => l
  }

let rec desaturate = (~amount=0.5, color) => {
  switch color {
  | #lab(_, _, _, _) as lab => lab->toLCH->desaturate
  | #lch(l, c, h, alpha) => #lch(l, c *. amount, h, alpha)
  }
}

let highlight = (~baseColor, factor) => {
  let baseL = luminance(baseColor)

  x =>
    switch x {
    | #lab(l, _a, _b, _alpha) as c =>
      lighten((baseL > 50. ? l +. (factor |> float_of_int) > 100. ? -1 : 1 : 1) * factor, c)
    }
}

let contrast = (color1, color2) => {
  let lum1 = luminance(color1)
  let lum2 = luminance(color2)
  let l1 = Js.Math.max_float(lum1, lum2)
  let l2 = Js.Math.min_float(lum1, lum2)
  (l1 +. 0.55) /. (l2 +. 0.55)
}

let getContrastFactor = x =>
  switch x {
  | (AAAA, Large) => 15.
  | (AAAA, Normal) => 21.
  | (A, Large) => 2.25
  | (A, Normal) => 2.75
  | (AA, Large) => 3.
  | (AA, Normal) => 4.5
  | (AAA, Large) => 4.5
  | (AAA, Normal) => 7.
  }

let isContrastOk = (~level=AA, ~size=Normal, lab1, lab2) =>
  contrast(lab1, lab2) > getContrastFactor((level, size))

let getTextColor = (~level, ~size, initialColor) => {
  let lch = initialColor->toLCH
  let (l, c, h, a) = switch lch {
  | #lch(l, c, h, a) => (l, c, h, a)
  }
  let operator = l > 50. ? (a, b) => a -. b : (a, b) => a +. b

  let contrastFactor = getContrastFactor((level, size))

  // Formula is a linear regression based on the values from here: https://stackoverflow.com/questions/22031644/formula-for-contrast-ratio-threshold-in-cielab-space
  // y=-0.4048x^{2}+13.5808x-7.0160
  let naiveLDiff = 4.1292 *. contrastFactor +. 19.8566
  // let naiveLDiff2 =
  //   -0.4048 *. (contrastFactor *. contrastFactor) +. 13.5808 *. contrastFactor -. 7.0160
  let naiveL = operator(l, naiveLDiff)
  let retVal =
    naiveL > 100. || naiveL < 0.
      ? l > 50. ? #lch(0., 0., h, a) : #lch(100., 0., h, a)
      : #lch(naiveL, naiveLDiff > 50. ? c *. 0.4 : c *. 0.8, h, a)

  retVal
}

let getContrastColor = (
  ~lightColor=#lab(100., 0., 0., 1.),
  ~darkColor=#lab(10., 0., 0., 1.),
  ~tint=?,
  lab,
) => {
  let contrastFn = contrast(lab)
  let baseColor = darkColor |> contrastFn > (lightColor |> contrastFn) ? darkColor : lightColor
  switch tint {
  | None => baseColor
  | Some(#lab(_l, a, b, alpha)) => #lab(luminance(baseColor), a, b, alpha)
  | Some(#lch(_l, c, h, alpha)) => #lch(luminance(baseColor), c, h, alpha)->toLab
  }
}

let hslToP3 = hsl => {
  switch hsl {
  | #hsl(h, s, l) =>
    s === 0.
      ? #p3(l, l, l, 1.)
      : {
          let hue2rgb = (p, q, t) => {
            let t2 = t < 0. ? t +. 1. : t > 1. ? t -. 1. : t
            t2 < 1. /. 6.
              ? p +. (q -. p) *. 6. *. t2
              : t2 < 1. /. 2.
              ? q
              : t2 < 2. /. 3.
              ? p +. (q -. p) *. (2. /. 3. -. t2) *. 6.
              : p
          }
          let q = l < 0.5 ? l *. (1. +. s) : l +. s -. l *. s
          let p = 2. *. l -. q
          let r = hue2rgb(p, q, h +. 1. /. 3.)
          let g = hue2rgb(p, q, h)
          let b = hue2rgb(p, q, h -. 1. /. 3.)
          #p3(r, g, b, 1.)
        }
  }
}
