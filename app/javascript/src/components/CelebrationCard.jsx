import React from "react";
// import giftCard from "../../images/gift-g1.jpeg";

const CelebrationCard = () => {

  return (
    <div className="card shadow-sm p-4 rounded-4">
      <img 
        src="https://static-cdn.drawnames.com/Content/Assets/gifts-valentine.svg?nc=202407011621"
        alt="gifts"
        className="img-fluid mb-3"
      />
      <h1 className="fs-3 fw-bold">Name of current Participants</h1>
      <p className="text-muted">Hi Abc, good to see you again!</p>
      <div className="d-flex flex-column gap-2">
        <a href="#" className="btn btn-primary">
          Thursday, January 30, 2025
        </a>
        <a href="#" className="btn btn-primary">
          Set gift amount
        </a>
      </div>
    </div>
  );
}

export default CelebrationCard;
