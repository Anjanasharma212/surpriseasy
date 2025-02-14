import React from "react";
import GroupDetails from "./GroupDetails";

const GroupIndex = () => {
  return (
    <div className="container py-5">
      <div className="col-md-12 ">
        <div className="col-md-4 mb-4">
          <GroupDetails groupId={199}/>
        </div>
        
        <div className="col-md-4 mb-4">
          <div className="card shadow-sm p-4">
            <h2 className="fs-4 fw-semibold">My Drawn Name</h2>
            <a href="#" className="btn btn-primary mt-3">
              My Drawn Name
            </a>
          </div>
        </div>

        <div className="col-md-4 mb-4">
          <div className="card shadow-sm p-4">
            <h2 className="fs-4 fw-semibold">My Wish List</h2>
            <p className="text-muted">Tell everyone what gifts you'd like!</p>
            <a href="/items" className="btn btn-primary mt-3">
              Make a Wish List
            </a>
          </div>
        </div>

        <div className="col-md-4 mb-4">
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
        </div>
      </div>
    </div>
  );
}

export default GroupIndex;
