type canvasContext = {@set "fillStyle": string, "fillRect": (. int, int, int, int) => unit}
type canvasEl = {"getContext": (. string) => canvasContext}
@react.component
let make = () => {
  let canvasRef = React.useRef(Js.Nullable.null)
  let (lightness, setLightness) = React.useState(() => 50)
  let (a, setA) = React.useState(() => 10)
  let (b, setB) = React.useState(() => 10)
  Js.log3(lightness, a, b)
  React.useEffect1(() => {
    canvasRef.current
    ->Js.Nullable.toOption
    ->Belt.Option.forEach(c => {
      let ctx = c["getContext"](. "2d")
      ctx["fillStyle"] =
        Lab.toP3(
          #lab(
            lightness->float_of_int,
            a->float_of_int -. 255. /. 2.,
            b->float_of_int -. 255. /. 2.,
            1.,
          ),
        )->Lab.p3ToString
      ctx["fillRect"](. 0, 0, 300, 300)
    })
    None
  }, [lightness, a, b])

  <>
    <canvas ref={ReactDOM.Ref.domRef(canvasRef->Obj.magic)} width="450" height="450" />
    <br />
    <input
      type_="range"
      min="1"
      max="100"
      value={lightness->Belt.Int.toString}
      onChange={e => {
        let value = 0 + (e->ReactEvent.Form.target)["value"]->Belt.Option.getWithDefault(100)
        setLightness(_ => value)
      }}
    />
    <br />
    <input
      type_="range"
      min="0"
      max="255"
      value={a->Belt.Int.toString}
      onChange={e => {
        let value = (e->ReactEvent.Form.target)["value"]->Belt.Option.getWithDefault(0)
        setA(_ => value)
      }}
    />
    <br />
    <input
      type_="range"
      min="0"
      max="255"
      value={b->Belt.Int.toString}
      onChange={e => {
        let value = (e->ReactEvent.Form.target)["value"]->Belt.Option.getWithDefault(0)
        setB(_ => value)
      }}
    />
  </>
}
