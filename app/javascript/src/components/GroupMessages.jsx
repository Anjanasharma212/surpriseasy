import React, { useState, useEffect } from "react";

const GroupMessages = ({ groupId }) => {
  const [messages, setMessages] = useState([]);
  const [newMessage, setNewMessage] = useState("");
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetch(`/groups/${groupId}/messages.json`)
      .then((res) => res.json())
      .then((data) => {
        setMessages(data);
        setLoading(false);
      })
      .catch((err) => {
        console.error("Error fetching messages:", err);
        setLoading(false);
      });
  }, [groupId]);

  const sendMessage = async () => {
    if (!newMessage.trim()) return;
    const csrfToken = document.querySelector('meta[name="csrf-token"]')?.getAttribute('content');

    const response = await fetch(`/groups/${groupId}/messages`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": csrfToken
      },
      body: JSON.stringify({ message: { content: newMessage, is_anonymous: false }})
    });

    if (response.ok) {
      const responseData = await response.json();
      const messageData = responseData.message;
      setMessages([...messages, messageData]);
      setNewMessage("");
    } else {
      console.error("Failed to send message");
    }
  };

  if (loading) return <div>Loading messages...</div>;

  return (
    <div className="group-show-card messages-card">
      <div className="group-card-content">
        <h2 className="group-card-title">Group Messages</h2>
        
        <div className="messages-list">
          {messages.length > 0 ? (
            messages.map((msg) => (
              <div key={msg.id} className="message-item">
                <div className="message-header">
                  <span className="message-sender">{msg.sender_name}</span>
                  <span className="message-time">
                    {msg.sent_at ? new Date(msg.sent_at).toLocaleString() : "Unknown Time"}
                  </span>
                </div>
                <p className="message-text">{msg.content}</p>
              </div>
            ))
          ) : (
            <p className="no-messages-text">No messages yet.</p>
          )}
        </div>

        <div className="message-input-container">
          <input
            type="text"
            className="message-input"
            placeholder="Write a message..."
            value={newMessage}
            onChange={(e) => setNewMessage(e.target.value)}
            onKeyPress={(e) => e.key === 'Enter' && sendMessage()}
          />
          <button className="send-btn" onClick={sendMessage}>
            ➤
          </button>
        </div>
      </div>
    </div>
  );
};

export default GroupMessages;