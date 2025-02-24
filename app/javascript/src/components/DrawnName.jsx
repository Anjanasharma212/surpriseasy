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
        const response = await fetch(`/participants/${participantId}/my_drawn_name.json`, { method: "GET" })
        if (!response.ok) throw new Error("Failed to fetch drawn name");

        const data = await response.json();

        if (data.error) {
          setError(data.error);
        } else {
          setDrawnName(
            data.drawn_name
              ? { id: data.drawn_name.id, name: data.drawn_name.name || `User ${data.drawn_name.id}` }
              : null
          );
          setGroupId(data.group_id);
        }
      } catch {
        setError("Failed to fetch drawn name.");
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
          "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]')?.getAttribute("content"),
        },
        body: JSON.stringify(requestData),
      });

      const responseData = await response.json();

      if (response.ok) {
        setSuccess("Message sent anonymously!");
        setMessage("");
      } else {
        setError(responseData.errors?.join(", ") || "Failed to send message.");
      }
    } catch {
      setError("An error occurred while sending the message.");
    } finally {
      setLoading(false);
    }
  };

  return (
    <div class="page-wrapper">
      <div className="drawn-page-container">
        {/* Left Side - My Drawn Name */}
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
                <span className="wishlist-count">0 gifts</span>
              </button>

              <div className="no-gifts-section">
                <p>No gifts requested yet</p>
                <a href="#" className="ask-anonymous-link">
                  Ask {drawnName.name} anonymously to enter a wish list
                </a>
              </div>

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

        {/* Right Side - Gift Finder */}
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
