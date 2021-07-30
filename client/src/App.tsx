import React from "react";
import "./App.css";
import { Dnd } from "./ReactBeautifulDnd";
import { Select } from "linear-common/Select";
import { Tiptap } from "./Editor";
import "./Markdown";
import hljs from "highlight.js";
console.log(hljs.highlightAuto("<span>Hello World!</span>"));

function App() {
  return (
    <>
      <Tiptap />
      <Select />
      <Dnd />
    </>
  );
}

export default App;
