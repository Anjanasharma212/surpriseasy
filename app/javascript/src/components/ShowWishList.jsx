import React from "react";

const ShowWishList = () => {

  return (
    <div className="card shadow-sm p-4">
      <h2 className="fs-4 fw-semibold">Wish List</h2>
      <p className="text-muted">Group Member who are drawing Name</p>

      <div className="wishlist-details mt-3">
        <div className="participant-row mb-3">
          <div className="participant-info d-flex align-items-center">
            
          </div>
        </div>
      </div>
      <a href="#" className="btn btn-primary mt-3">
        Add a children wishlist
      </a>
    </div>
  );
};

export default ShowWishList;
