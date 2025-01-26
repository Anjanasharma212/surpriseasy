import React from "react";
import CelebrationCard from "./CelebrationCard";
import CreateWishList from "./CreateWishList";
import MyDrawnName from "./MyDrawnName";
import ShowWishList from "./ShowWishList";

const GroupIndex = () => {
  return (
    <div className="container py-5">
      <div className="col-md-12 ">
        <div className="col-md-4 mb-4">
          <CelebrationCard />
        </div>
        
        <div className="col-md-4 mb-4">
          <MyDrawnName />
        </div>

        <div className="col-md-4 mb-4">
          <CreateWishList />
        </div>

        <div className="col-md-4 mb-4">
          <ShowWishList />
        </div>
      </div>
    </div>
  );
}

export default GroupIndex;
