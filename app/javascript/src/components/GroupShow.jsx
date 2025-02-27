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
        console.log("Group data:", data);
        console.log("Logged in participant:", data.logged_in_participant);
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
    <div className="group-show-container">
      <div className="group-show-grid">
        <div className="group-show-card group-info-card">
          <div className="group-card-content">
            <img
              src="https://static-cdn.drawnames.com/Content/Assets/gifts-valentine.svg?nc=202407011621"
              alt="gifts"
              className="group-card-image"
            />
            <h2 className="group-card-title">{group.name}</h2>
            {group.logged_in_participant && (
              <p className="group-card-text">
                Hi {group.logged_in_participant.name} ({group.logged_in_participant.email}), good to see you!
              </p>
            )}
            <div className="group-card-buttons">
              <a href="#" className="group-card-btn">
                🎉 {new Date(group.event_date).toLocaleDateString()}
              </a>
              <a href="#" className="group-card-btn">
                💰 ${group.budget}
              </a>
            </div>
          </div>
        </div>
  
        <div className="group-show-card draw-name-card">
          <div className="group-card-content">
            <h2 className="group-card-title">My Drawn Name</h2>
            {group?.logged_in_participant?.drawn_name_id ? (
              <a
                href={`/participants/${group.logged_in_participant.drawn_name_id}/my_drawn_name`}
                className="group-card-btn"
              >
                My Drawn Name
              </a>
            ) : (
              <>
                <button
                  className="group-card-btn draw-btn"
                  onClick={() => handleDrawName(group.logged_in_participant.id)}
                  disabled={isDrawing}
                >
                  {isDrawing ? "Drawing..." : "Draw Name"}
                </button>
                {error && <p className="error-text">{error}</p>}
              </>
            )}
          </div>
        </div>
  
        <div className="group-show-card wishlist-card">
          <div className="group-card-content">
            <h2 className="group-card-title">My Wish List</h2>
            <p className="group-card-text">Tell everyone what gifts you'd like!</p>
            {group?.logged_in_participant ? (
              (() => {
                const currentParticipant = group.participants.find(
                  p => p.participant_id === group.logged_in_participant.id
                );
                
                if (currentParticipant?.wishlist_id && currentParticipant?.wishlist_items_count > 0) {
                  return (
                    <a 
                      href={`/items?wishlist_id=${currentParticipant.wishlist_id}&group_id=${groupId}`} 
                      className="group-card-btn"
                    >
                      Update Wish List
                    </a>
                  );
                } else {
                  return (
                    <a 
                      href={`/items?group_id=${groupId}`} 
                      className="group-card-btn"
                    >
                      Make a Wish List
                    </a>
                  );
                }
              })()
            ) : (
              <span>Loading...</span>
            )}
          </div>
        </div>
  
        <div className="group-show-card wishlists-overview-card">
          <div className="group-card-content">
            <h2 className="group-card-title">Wish Lists</h2>
            <p className="group-card-text">Group Members Who Are Drawing Names</p>
            <div className="participants-list">
              {group?.participants?.map((participant) => (
                <div key={participant.participant_id} className="participant-item">
                  <div className="participant-info">
                    {participant.wishlist_id ? (
                      <a 
                        href={`/items?wishlist_id=${participant.wishlist_id}&group_id=${groupId}`} 
                        className="participant-link"
                      >
                        {participant.email}
                        {participant.wishlist_items_count > 0 && (
                          <span className="wishlist-count">({participant.wishlist_items_count} items)</span>
                        )}
                      </a>
                    ) : (
                      <span className="participant-email">{participant.email} (No Wishlist)</span>
                    )}
                  </div>
                  <div className="wishlist-preview">
                    {participant.wishlist_items_count > 0 ? (
                      <>
                        <div className="wishlist-icons">
                          {participant.wishlist_items.slice(0, 3).map((item, index) => (
                            <img
                              key={index}
                              src={item.image_url || 'default-item.png'}
                              alt={item.item_name || 'Wishlist item'}
                              className="wishlist-icon"
                            />
                          ))}
                        </div>
                        {participant.wishlist_items_count > 3 && (
                          <span className="wishlist-count">+{participant.wishlist_items_count - 3}</span>
                        )}
                      </>
                    ) : (
                      <span className="no-items-text">No wishlist items</span>
                    )}
                  </div>
                </div>
              ))}
            </div>
            <a href="#" className="group-card-btn">Add a children's wishlist</a>
          </div>
        </div>
  
        <div className="group-show-card wishlists-overview-card">
          <div className="group-card-content">
            <GroupMessages groupId={groupId} />
          </div>
        </div>
      </div>
    </div>
  );
}

export default GroupShow;
