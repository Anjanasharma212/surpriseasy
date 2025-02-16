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
        'X-CSRF-Token': csrfToken
      },
      body: JSON.stringify({ message: newMessage }),
    });

    if (response.ok) {
      const messageData = await response.json();
      setMessages([...messages, messageData]);
      setNewMessage("");
    } else {
      console.error("Failed to send message");
    }
  };

  if (loading) return <div>Loading messages...</div>;

  return (
    <div className="group-messages-wrapper">
      <div className="group-messages-container">
        <h3 className="group-messages-title">Group Messages</h3>

        <div className="messages-box">
          {messages.length > 0 ? (
            messages.map((msg) => (
              <div key={msg.id} className="message-card">
                <div className="message-header">
                  <span className="sender-name">{msg.sender_name}</span>
                  <span className="message-time">
                    {new Date(msg.sent_at).toLocaleString()}
                  </span>
                </div>
                <p className="message-content">{msg.message}</p>
              </div>
            ))
          ) : (
            <p className="no-messages">No messages yet.</p>
          )}
        </div>

        <div className="message-input-box">
          <input
            type="text"
            className="message-input"
            placeholder="Write a message..."
            value={newMessage}
            onChange={(e) => setNewMessage(e.target.value)}
          />
          <button className="send-button" onClick={sendMessage}>
            ➤
          </button>
        </div>
      </div>
    </div>
  );
};

export default GroupMessages;
