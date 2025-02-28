import React, { useEffect, useState } from "react";
import GroupMessages from "./GroupMessages";

const GroupShow = () => {
  const [group, setGroup] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [drawnParticipant, setDrawnParticipant] = useState(null);
  const [isDrawing, setIsDrawing] = useState(false);

  useEffect(() => {
    const groupId = window.location.pathname.split('/').pop();
    setLoading(true);

    fetch(`/groups/${groupId}.json`, {
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/json"
      },
      credentials: "include",
    })
      .then(async (res) => {
        if (!res.ok) {
          const errorData = await res.json();
          throw new Error(errorData.error || 'Failed to fetch group');
        }
        return res.json();
      })
      .then((data) => {
        setGroup(data);
        // Find drawn participant if drawn_name_id exists
        if (data.logged_in_participant?.drawn_name_id) {
          const drawn = data.participants.find(p => p.id === data.logged_in_participant.drawn_name_id);
          setDrawnParticipant(drawn);
        }
        setError(null);
      })
      .catch((error) => {
        console.error("Error fetching group:", error);
        setError(error.message);
      })  
      .finally(() => {
        setLoading(false);
      });
  }, []);

  const handleDrawnNameClick = () => {
    if (!group?.logged_in_participant?.drawn_name_id) return;
    
    const drawn = group.participants.find(
      p => p.id === group.logged_in_participant.drawn_name_id
    );
    
    if (drawn) {
      setDrawnParticipant(drawn);
    }
  };

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

  if (loading) return <p className="text-center">Loading...</p>;
  if (error) return <p className="text-red-600 text-center">{error}</p>;
  if (!group) return <p className="text-center">No group found.</p>;

  return (
    <div className="group-show-container">
      {/* <h1 className="group-title">{group.group_name}</h1> */}
      
      {/* <div className="event-details">
        <p className="event-date">
          <span>📅</span> {new Date(group.event_date).toLocaleDateString("en-US", {
            weekday: "long",
            year: "numeric",
            month: "long",
            day: "numeric",
          })}
        </p>
        <p className="budget">Budget: ${group.budget}</p>
      </div> */}

      {/* {group.logged_in_participant?.drawn_name_id && (
        <div className="drawn-name-section">
          <h2>Your Drawn Name</h2>
          <button 
            onClick={handleDrawnNameClick}
            className="drawn-name-button"
          >
            {drawnParticipant ? (
              <span>{drawnParticipant.user.name}</span>
            ) : (
              <span>Click to reveal</span>
            )}
          </button>
        </div>
      )} */}

      {/* <div className="participants-section">
        <h2>Participants</h2>
        <div className="participants-list">
          {group.participants?.map((participant) => (
            <div key={participant.id} className="participant-card">
              <h3>{participant.user.name}</h3>
              <p>{participant.user.email}</p>
              {participant.wishlist && (
                <div className="wishlist-section">
                  <h4>Wishlist ({participant.wishlist.wishlist_items_count} items)</h4>
                  <div className="wishlist-items">
                    {participant.wishlist.wishlist_items.map((item) => (
                      <div key={item.id} className="wishlist-item">
                        <img src={item.image_url} alt={item.item_name} />
                        <p>{item.item_name}</p>
                      </div>
                    ))}
                  </div>
                </div>
              )}
            </div>
          ))}
        </div>
      </div> */}

      <div className="floating-gifts">
        {[1, 2, 3, 4, 5, 6].map((num) => (
          <div key={num} className={`gift gift-${num}`} />
        ))}
      </div>

      <div className="group-show-grid">
        <div className="group-show-card group-info-card">
          <div className="group-card-content">
            <img
              src="https://static-cdn.drawnames.com/Content/Assets/gifts-valentine.svg?nc=202407011621"
              alt="gifts"
              className="group-card-image"
            />
            <h2 className="group-card-title">{group.group_name}</h2>
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
                      href={`/items?wishlist_id=${currentParticipant.wishlist_id}&group_id=${group.id}`} 
                      className="group-card-btn"
                    >
                      Update Wish List
                    </a>
                  );
                } else {
                  return (
                    <a 
                      href={`/items?group_id=${group.id}`} 
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
                <div key={participant.id} className="participant-item">
                  <div className="participant-info">
                    {participant.wishlist_id ? (
                      <a 
                        href={`/items?wishlist_id=${participant.wishlist_id}&group_id=${group.id}`} 
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
                    {participant.wishlist_items?.length > 0 ? (
                      <>
                        <div className="wishlist-icons">
                          {participant.wishlist_items.slice(0, 3).map((item) => (
                            <img
                              key={item.id}
                              src={item.image_url || '/images/default-item.png'}
                              alt={item.item_name || 'Wishlist item'}
                              className="wishlist-icon"
                            />
                          ))}
                        </div>
                        {participant.wishlist_items.length > 3 && (
                          <span className="wishlist-count">+{participant.wishlist_items.length - 3}</span>
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
            <GroupMessages groupId={group.id} />
          </div>
        </div>
      </div>
    </div>
  );
};

export default GroupShow;
