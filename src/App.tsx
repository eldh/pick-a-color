import React from "react";
import ReactDOM from "react-dom";
import { make as ColorPicker } from "./ColorPicker.bs";

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
    <div style={{ margin: "40px" }}>
      <ColorPicker />
    </div>
  );
}

export default App;
