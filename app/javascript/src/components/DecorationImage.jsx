import React from "react";
import giftExchange from "../../images/gift-exchange.jpeg";

const DecorationImage = ({ alt }) => {
  return (
    <div className="decoration home">
       <img src={giftExchange} alt="Gift Exchange" />;
    </div>
  );
};

export default DecorationImage;
