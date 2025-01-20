// Run this example by adding <%= javascript_pack_tag 'hello_react' %> to the head of your layout file,
// like app/views/layouts/application.html.erb. All it does is render <div>Hello React</div> at the bottom
// of the page.

import React from "react";
import { createRoot } from "react-dom/client";

const Hello = (props) => {
  return <h1>Hello!! Welcome to {props.name} </h1>;
};

document.addEventListener("DOMContentLoaded", () => {
  const rootElement = document.getElementById("hello-react"); 
  if (rootElement) {
    const root = createRoot(rootElement); 
    root.render(<Hello name="SurpriSeasy" />); 
  }
});
