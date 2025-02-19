import React, { useEffect, useState } from "react";

const DrawnName = () => {
  const drawnElement = document.getElementById("drawn-name");
  const participantId = drawnElement ? drawnElement.dataset.participantId : null;

  const [drawnName, setDrawnName] = useState(null);
  const [groupId, setGroupId] = useState(null);
  const [error, setError] = useState(null);
  const [loading, setLoading] = useState(false);
  const [message, setMessage] = useState("");
  const [success, setSuccess] = useState(null);

  useEffect(() => {
    if (!participantId) {
      setError("Participant ID is missing.");
      return;
    }

    fetch(`/participants/${participantId}/my_drawn_name.json`, { method: "GET" })
      .then((response) => response.json())
      .then((data) => {
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
      })
      .catch(() => setError("Failed to fetch drawn name"));
  }, [participantId]);

  const sendAnonymousMessage = async () => {
    if (!message.trim()) {
      setError("Message cannot be empty.");
      return;
    }

    if (!drawnName || !drawnName.id) {
      setError("Recipient not found. Please try again later.");
      return;
    }

    if (!groupId) {
      setError("Group ID is missing.");
      return;
    }

    setLoading(true);
    setError(null);
    setSuccess(null);

    const csrfToken = document.querySelector('meta[name="csrf-token"]')?.getAttribute("content");

    const requestData = {
      message,
      receiver_id: drawnName.id,
      is_anonymous: "true"
    };

    try {
      const response = await fetch(`/groups/${groupId}/messages`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": csrfToken
        },
        body: JSON.stringify(requestData)
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
    <div className="container">
      <div className="card">
        <h1 className="card-title">My Drawn Name</h1>
        <div className="name">
          <h1 className="notranslate">{error ? error : drawnName?.name || "Loading..."}</h1>
        </div>

        {drawnName && (
          <>
            <div className="wishlist-section">
              <h2 className="wishlist-title">Wish list for {drawnName.name}</h2>
              <p className="wishlist-count">0 gifts</p>
              <div className="wishlist-placeholder">
                <p>No gifts requested yet</p>
                <a href="#" className="wishlist-action">Ask {drawnName.name} anonymously to enter a wish list</a>
              </div>
            </div>

            <div className="hobbies-section">
              <h2>Hobbies and interests</h2>
              <p>{drawnName.name} has not added any hobbies or interests.</p>
            </div>

            <div className="question-section max-w-lg mx-auto p-4">
              <h2 className="text-xl font-semibold text-gray-800 mb-4">
                Ask {drawnName.name} a question anonymously
              </h2>

              <div className="border rounded-lg p-4 shadow mb-4 bg-white">
                <textarea
                  className="w-full border p-2 rounded resize-none focus:outline-none focus:ring-2 focus:ring-green-400"
                  placeholder="Type in your anonymous question..."
                  maxLength="2048"
                  rows="4"
                  value={message}
                  onChange={(e) => setMessage(e.target.value)}
                ></textarea>
              </div>

              {error && <p className="text-red-500">{error}</p>}
              {success && <p className="text-green-500">{success}</p>}

              <button
                onClick={sendAnonymousMessage}
                className={`w-full py-2 rounded-lg mt-2 ${
                  loading ? "bg-gray-400 cursor-not-allowed" : "bg-blue-500 hover:bg-blue-600"
                } text-white`}
                disabled={loading}
              >
                {loading ? "Sending..." : "Send Mail"}
              </button>
            </div>

            <div className="wishlist-prompt">
              <p>You <strong>have not</strong> yet added your own wish list or hobbies.</p>
              <a href="#" className="button wishlist-button">Make a wish list</a>
            </div>

            <div className="giftfinder-section">
              <h2>Gift Finder</h2>
              <p>Find a gift for {drawnName.name}.</p>
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
