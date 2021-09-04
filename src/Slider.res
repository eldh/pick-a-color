type canvasContext = {@set "fillStyle": string, "fillRect": (. int, int, int, int) => unit}
type canvasEl = {"getContext": (. string) => canvasContext}
@react.component
let make = (~onValueChange,~value) => {
  let canvasRef = React.useRef(Js.Nullable.null)
  React.useEffect1(() => {
    canvasRef.current
    ->Js.Nullable.toOption
    ->Belt.Option.forEach(c => {
      let ctx = c["getContext"](. "2d")
      for hue in 0 to 500 {
        ctx["fillStyle"] = Lab.hslToP3(#hsl(hue->float_of_int /. 500., 1., 0.5))->Lab.p3ToString
        ctx["fillRect"](. hue, 0, 1, 40)
      }
    })
    None
  }, [])
<>
  <canvas ref={ReactDOM.Ref.domRef(canvasRef->Obj.magic)} width="500" height="40" />
  <Point left=300 />
</>
}

module Point = [%styled.div (~left) => {j|
  left: $(left)px;
  position: absolute;
  top: 0;
  background-color: #fff;
  width: 3px;
  height: 40px;
|j}];