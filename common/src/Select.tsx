import * as React from "react";
import SelectLib from "react-select";

const options = [
  { value: "chocolate", label: "Chocolate" },
  { value: "strawberry", label: "Strawberry" },
  { value: "vanilla", label: "Vanilla" },
];

export function Select() {
  return <SelectLib options={options} />;
}
