import React from "react";
import { make as ReApp } from "./App.bs";
import { Fallback } from "./Fallback";
const goodBrowser = CSS.supports("color", "lch(5% 10 10)");
function App() {
  return (
    <div
      style={{
        background:
          "linear-gradient(120deg, lch(1% 0 190),lch(3% 0 250), lch(5% 0 300))",
        display: "flex",
        alignItems: "center",
        justifyContent: "center",
        minHeight: "100vh"
      }}
    >
      {goodBrowser ? <ReApp /> : <Fallback />}
    </div>
  );
}

export default App;
