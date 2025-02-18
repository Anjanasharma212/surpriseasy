import React, { useState, useEffect } from "react";
import GroupMessages from "./GroupMessages";

const GroupShow = ()=> {
  const groupElement = document.getElementById("participants-details");
  const groupId = groupElement ? groupElement.dataset.groupId : null;
  const [group, setGroup] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [isDrawing, setIsDrawing] = useState(false);

  useEffect(() => {
    fetch(`/groups/${groupId}.json`)
      .then((res) => {
        if (!res.ok) throw new Error("Network response was not ok");
        return res.json();
      })
      .then((data) => {
        setGroup(data);
        setLoading(false);
      })
      .catch((err) => {
        setError(err.message);
        setLoading(false);
      });
  }, [groupId]);

  const handleDrawName = (participantId) => {
    setIsDrawing(true);
    setError(null);
    const csrfToken = document.querySelector('meta[name="csrf-token"]')?.getAttribute('content');
    fetch(`/participants/${participantId}/my_drawn_name.json`, {
      method: "POST",
      headers: { "Content-Type": "application/json", 'X-CSRF-Token': csrfToken },
    })
      .then((response) => response.json())
      .then((data) => {
        if (data.drawn_name_id) {
          window.location.href = `/participants/${data.drawn_name_id}/my_drawn_name`;
        } else {
          setError("No available participants left.");
        }
      })
      .catch(() => setError("Failed to fetch drawn name"))
      .finally(() => setIsDrawing(false));
  };

  if (loading) return <div>Loading group data...</div>;
  if (error) return <div>Error: {error}</div>;

  return (
    <div className="container py-5">
      <div className="col-md-12 ">
        <div className="col-md-4 mb-4">
          <div className="shadow-sm p-4 rounded-4">
            <img
              src="https://static-cdn.drawnames.com/Content/Assets/gifts-valentine.svg?nc=202407011621"
              alt="gifts"
              className="img-fluid mb-3"
            />
            <div>
              <h2 className="fs-3 fw-bold">{group.name}</h2>
              {group.logged_in_participant && (
                <p className="text-muted">
                  Hi {group.logged_in_participant.name} ({group.logged_in_participant.email}), good to see you!
                </p>
              )}
              <div className="d-flex flex-column gap-2">
                <a href="#" className="btn btn-primary">
                  🎉 {new Date(group.event_date).toLocaleDateString()}
                </a>
                <a href="#" className="btn btn-primary">
                  💰 ${group.budget}
                </a>
              </div>
            </div>
          </div>
        </div>

        <div className="col-md-4 mb-4">
          <div className="card shadow-sm p-4">
            <h2 className="fs-4 fw-semibold">My Drawn Name</h2>
            {group?.logged_in_participant?.drawn_name_id ? (
              <a
                href={`/participants/${group.logged_in_participant.drawn_name_id}/my_drawn_name`}
                className="btn btn-primary mt-3"
              >
                My Drawn Name
              </a>
            ) : (
              <>
                <button
                  className="btn btn-success mt-3"
                  onClick={() => handleDrawName(group.logged_in_participant.id)}
                  disabled={isDrawing}
                >
                  {isDrawing ? "Drawing..." : "Draw Name"}
                </button>
                {error && <p className="text-danger mt-2">{error}</p>}
              </>
            )}
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
            <h2 className="fs-4 fw-semibold">Wish Lists</h2>
            <p className="text-muted">Group Members Who Are Drawing Names</p>
            <div>
            {group.participants?.length ? (
              group.participants.map(({ participant_id, email, wishlist_id, wishlist_items_count, wishlist_items }) => (
                <div key={participant_id} className="participant-row mb-3 d-flex align-items-center justify-content-between">
                  {wishlist_id ? (
                    <a href={`/groups/${groupId}/participants/${participant_id}/wishlists/${wishlist_id}`} className="participant-name">
                      {email}
                    </a>
                  ) : (
                    <span className="participant-name">{email} (No Wishlist)</span>
                  )}

                  {wishlist_items_count > 0 ? (
                    <div className="wishlist-items d-flex ms-2">
                      {wishlist_items.slice(0, 3).map((item, index) => (
                        <img
                          key={index}
                          src={item.image_url || 'cap.jpeg'}
                          alt={item.item_name || 'Wishlist item'}
                          className="wishlist-item-icon ms-2"
                          width="30"
                          height="30"
                        />
                      ))}
                      {wishlist_items_count > 3 && (
                        <span className="wishlist-extra ms-2">+{wishlist_items_count - 3}</span>
                      )}
                    </div>
                  ) : (
                    <span className="text-muted ms-2">No wishlist items</span>
                  )}
                </div>  
              ))
            ) : (
              <p className="text-muted">No participants in this group.</p>
            )}
            </div>
            <a href="#" className="btn btn-primary mt-3">Add a children's wishlist</a>
          </div>
        </div>

        <GroupMessages groupId={groupId} />
      </div>
    </div>
  );
}

export default GroupShow;
