import React, { useEffect, useState } from "react";

const DrawnName = () => {
  const drawnElement = document.getElementById("drawn-name");
  const participantId = drawnElement ? drawnElement.dataset.participantId : null;
  const [drawnName, setDrawnName] = useState(null);
  const [error, setError] = useState(null);
  const [loading, setLoading] = useState(null);
  useEffect(() => {
    if (!participantId) {
      setError("Participant ID is missing.");
      setLoading(false);
      return;
    }

    fetch(`/participants/${participantId}/my_drawn_name.json`, { method: "GET" })
      .then((response) => {
        if (!response.ok) throw new Error("Participant not found");
        return response.json();
      })
      .then((data) => {
        if (data.error) {
          setError(data.error);
        } else {
          setDrawnName(data.drawn_name);
        }
      })
      .catch(() => setError("Failed to fetch drawn name"))
      .finally(() => setLoading(false));
  }, [participantId]);

  return (
    <div className="container">
      <div className="card">
        <h1 className="card-title">My Drawn Name</h1>
        <div className="name">
          <h1 className="notranslate">{error ? error : drawnName || "Loading..."}</h1>
        </div>

        {drawnName && (
          <>
            <div className="wishlist-section">
              <h2 className="wishlist-title">Wish list for {drawnName}</h2>
              <p className="wishlist-count">0 gifts</p>
              <div className="wishlist-placeholder">
                <p>No gifts requested yet</p>
                <a href="#" className="wishlist-action">Ask {drawnName} anonymously to enter a wish list</a>
              </div>
            </div>

            <div className="hobbies-section">
              <h2>Hobbies and interests</h2>
              <p>{drawnName} has not added any hobbies or interests.</p>
            </div>

            <div className="question-section">
              <h2>Ask {drawnName} a question anonymously</h2>
              <p>You can ask an anonymous question as soon as {drawnName} has accepted the invitation.</p>
            </div>

            <div className="wishlist-prompt">
              <p>You <strong>have not</strong> yet added your own wish list or hobbies.</p>
              <a href="#" className="button wishlist-button">Make a wish list</a>
            </div>

            <div className="giftfinder-section">
              <h2>Gift Finder</h2>
              <p>Find a gift for {drawnName}.</p>
              <a href="#" className="button giftfinder-button">Search in Gift Finder</a>
            </div>
          </>
        )}

        <div className="group-page-link">
          <a href="/secret-santa-generator/overview/your-group-link">Visit the group page</a>
        </div>
      </div>
    </div>
  );
};

export default DrawnName;
