import React from "react";
import ReactDOM from "react-dom";
import "./App.css";
import "./Markdown";
import hljs from "highlight.js";
console.log(hljs.highlightAuto("<span>Hello World!</span>"));
import favicon from "./favicon.png";

function App() {
  const canvasRef = React.useRef<HTMLCanvasElement>(null);
  const [hue, setHue] = React.useState(100);
  React.useEffect(() => {
    var ctx = canvasRef.current?.getContext("2d");
    if (ctx) {
      for (var i = 0; i < 150; i++) {
        for (var j = 0; j < 150; j++) {
          ctx.fillStyle = `color(display-p3 ${(i + hue) / 300} ${
            (j + hue) / 300
          } ${(i + j + hue) / 450})`;
          ctx.fillRect(i * 3, j * 3, 3, 3);
        }
      }
    }
  }, [hue]);
  return (
    <>
      <canvas ref={canvasRef} id="tutorial" width="450" height="450" />
      <br />
      <input
        type="range"
        min="1"
        max="150"
        value={hue}
        onChange={(e) =>
          ReactDOM.unstable_batchedUpdates(() =>
            setHue(parseInt(e.target.value, 10))
          )
        }
      />
      {hue}
    </>
  );
}

export default App;
