import React from "react";
import giftExchange from '../../assets/images/gift-exchange.jpeg';

const DecorationImage = ({ alt }) => {
  return (
    <div className="decoration home">
      <img src={giftExchange} alt={alt} />
    </div>
  );
};

export default DecorationImage;
