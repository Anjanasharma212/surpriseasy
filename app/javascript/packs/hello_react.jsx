import React from "react";
import { createRoot } from "react-dom/client";
import Layout from "../src/components/Layout";
import HelloReact from "../src/components/HelloReact";
import GiftGenerator from "../src/components/GiftGenerator";
import GroupIndex from "../src/components/GroupIndex";
import ItemList from "../src/components/ItemList";
import GroupShow from "../src/components/GroupShow";
import WishlistShow from "../src/components/WishlistShow.jsx";

const mountReactComponent = (id, Component) => {
  const rootElement = document.getElementById(id);
  if (rootElement) {
    createRoot(rootElement).render(
    <Layout>
      <Component />
    </Layout>);
  }
};

document.addEventListener("DOMContentLoaded", () => {
  mountReactComponent("react-root", HelloReact); 
  mountReactComponent("gift-generator-root", GiftGenerator);
  mountReactComponent("my-group-root", GroupIndex);
  mountReactComponent("items-list", ItemList);
  mountReactComponent("participants-details", GroupShow);
  mountReactComponent("wishlist-items", WishlistShow);
});
