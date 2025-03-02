import React, { useEffect, useState } from "react";

const DrawnName = () => {
  const drawnElement = document.getElementById("drawn-name");
  const participantId = drawnElement?.dataset?.participantId || null;

  const [drawnName, setDrawnName] = useState(null);
  const [groupId, setGroupId] = useState(null);
  const [error, setError] = useState(null);
  const [loading, setLoading] = useState(false);
  const [message, setMessage] = useState("");
  const [success, setSuccess] = useState(null);
  const [searchQuery, setSearchQuery] = useState("");

  useEffect(() => {
    if (!participantId) {
      setError("Participant ID is missing.");
      return;
    }

    const fetchDrawnName = async () => {
      try {
        const response = await fetch(`/participants/${participantId}.json`, { 
          method: "GET",
          headers: {
            "Accept": "application/json",
            "Content-Type": "application/json",
          }
        });

        if (!response.ok) {
          const errorData = await response.json();
          throw new Error(errorData.error || "Failed to fetch drawn name");
        }

        const data = await response.json();
        if (data.drawn_name) {
          setDrawnName({
            id: data.drawn_name.id,
            name: data.drawn_name.name,
            email: data.drawn_name.email,
            wishlistId: data.drawn_name.wishlist_id,
            wishlistItemsCount: data.drawn_name.wishlist_items_count
          });
          setGroupId(data.group_id);
          setError(null);
        } else {
          setError("No drawn name assigned yet.");
        }
      } catch (err) {
        setError(err.message || "Failed to fetch drawn name.");
      }
    };

    fetchDrawnName();
  }, [participantId]);

  const sendAnonymousMessage = async () => {
    if (!message.trim() || !drawnName?.id || !groupId) {
      setError("Please fill required fields before sending.");
      return;
    }

    setLoading(true);
    setError(null);
    setSuccess(null);

    const requestData = {
      message: {
        content: message,
        receiver_id: drawnName.id,
        is_anonymous: true,
      },
    };

    try {
      const response = await fetch(`/groups/${groupId}/messages`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]')?.getAttribute("content"),
        },
        body: JSON.stringify(requestData),
      });

      const responseData = await response.json();

      if (response.ok) {
        setSuccess("Message sent anonymously!");
        setMessage("");
      } else {
        setError(responseData.error || "Failed to send message.");
      }
    } catch (err) {
      setError("An error occurred while sending the message.");
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="page-wrapper">
      <div className="drawn-page-container">
        <div className="drawn-name-section">
          <div className="drawn-name-display">
            <h1 className="drawn-name-title">My Drawn Name</h1>
            <h2 className="drawn-name-text notranslate">
              {error || drawnName?.name || "Loading..."}
            </h2>
          </div>

          {drawnName && (
            <>
              <button className="wishlist-button">
                Wish list for {drawnName.name}
                <span className="wishlist-count">
                  {drawnName.wishlistItemsCount} gifts
                </span>
              </button>

              {drawnName.wishlistItemsCount === 0 ? (
                <div className="no-gifts-section">
                  <p>No gifts requested yet</p>
                  <a href="#" className="ask-anonymous-link">
                    Ask {drawnName.name} anonymously to enter a wish list
                  </a>
                </div>
              ) : (
                <a 
                  href={`/items?wishlist_id=${drawnName.wishlistId}`} 
                  className="view-wishlist-link"
                >
                  View Wishlist
                </a>
              )}

              <div className="info-section">
                <div className="info-header">
                  <i className="icon-hobbies"></i>
                  <h2>Hobbies and interests</h2>
                </div>
                <p className="info-text">
                  {drawnName.name} has not added any hobbies or interests.
                </p>

                <div className="info-header">
                  <i className="icon-question"></i>
                  <h2>Ask {drawnName.name} a question anonymously</h2>
                </div>
                
                <textarea
                  className="drawn-question-input"
                  placeholder="Type in your anonymous question..."
                  maxLength="2048"
                  value={message}
                  onChange={(e) => setMessage(e.target.value)}
                ></textarea>

                {error && <p className="drawn-error-message">{error}</p>}
                {success && <p className="drawn-success-message">{success}</p>}

                <button
                  onClick={sendAnonymousMessage}
                  className="drawn-send-button"
                  disabled={loading}
                >
                  {loading ? "Sending..." : "Send Message"}
                </button>
              </div>
            </>
          )}
        </div>

        <div className="gift-finder-section">
          <h1 className="gift-finder-header">Gift Finder</h1>
          
          <div className="search-container">
            <input 
              type="text" 
              className="search-input"
              placeholder="Search in Gift Finder"
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
            />
          </div>

          <div className="gift-finder-content">
            <div className="gift-finder-popup">
              <h2 className="popup-title">Gift Finder</h2>
              <p className="popup-text">Find a gift for {drawnName?.name}.</p>
              <button className="search-button">
                Search in Gift Finder
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default DrawnName;
