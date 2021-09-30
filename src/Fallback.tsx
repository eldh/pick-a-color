import React from "react";
const goodBrowser = CSS.supports("color", "lch(5% 10 10)");
export function Fallback() {
  return (
    <div
      style={{
        color: "#aaa",
        fontSize: "18px",
        lineHeight: "1.25em"
      }}
    >
      This thing only works in cool browsers.
      <div style={{ color: "#666" }}>Safari 15 is cool.</div>
    </div>
  );
}
