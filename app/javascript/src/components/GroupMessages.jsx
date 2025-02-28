import React, { useState, useEffect } from "react";

const GroupMessages = ({ groupId }) => {
  const [messages, setMessages] = useState([]);
  const [newMessage, setNewMessage] = useState("");
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    fetchMessages();
  }, [groupId]);

  const fetchMessages = async () => {
    try {
      setLoading(true);
      setError(null);
      const res = await fetch(`/groups/${groupId}/messages.json`);
      if (!res.ok) {
        const errorData = await res.json();
        throw new Error(errorData.error || 'Failed to fetch messages');
      }
      const data = await res.json();
      setMessages(data);
    } catch (err) {
      setError(err.message);
      console.error("Error fetching messages:", err);
    } finally {
      setLoading(false);
    }
  };

  const sendMessage = async () => {
    if (!newMessage.trim()) return;
    
    try {
      setError(null);
      const csrfToken = document.querySelector('meta[name="csrf-token"]')?.getAttribute('content');

      const response = await fetch(`/groups/${groupId}/messages`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": csrfToken
        },
        body: JSON.stringify({ message: { content: newMessage, is_anonymous: false }})
      });

      const responseData = await response.json();
      
      if (!response.ok) {
        throw new Error(responseData.error || responseData.errors?.join(', ') || 'Failed to send message');
      }

      setMessages(prevMessages => [...prevMessages, responseData]);
      setNewMessage("");
      
      fetchMessages();
      
    } catch (err) {
      setError(err.message);
      console.error("Error sending message:", err);
    }
  };

  const formatDateTime = (isoString) => {
    if (!isoString) return "";
    
    try {
      return new Date(isoString).toLocaleString('en-US', {
        year: 'numeric',
        month: 'short',
        day: 'numeric',
        hour: '2-digit',
        minute: '2-digit'
      });
    } catch (error) {
      console.error('Date formatting error:', error);
      return "";
    }
  };

  if (loading) return <div>Loading messages...</div>;
  if (error) return <div className="error-message">{error}</div>;

  return (
    <div className="group-show-card messages-card">
      <div className="group-card-content">
        <h2 className="group-card-title">Group Messages</h2>
        
        <div className="messages-list">
          {messages.length > 0 ? (
            messages.map((msg) => (
              <div key={`message-${msg.id}`} className="message-item">
                <div className="message-header">
                  <span className="message-sender">{msg.sender_name}</span>
                  <span className="message-time">
                    {formatDateTime(msg.sent_at)}
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
