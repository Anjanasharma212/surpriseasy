import React from "react";
import DecorationImage from './DecorationImage';
import ContentSection from './ContentSection';
import './Main.css';

const Main = () => {
  return (
    <div className="main-container">
      <div className="content-section">
        <ContentSection />
      </div>
      <div className="image-section">
        <DecorationImage alt="Draw names" />
      </div>
    </div>
  );
};

export default Main;
