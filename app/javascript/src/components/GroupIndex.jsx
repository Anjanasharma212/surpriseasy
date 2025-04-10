import React, { useEffect, useState } from "react";
import { FaTrashAlt } from "react-icons/fa";
import indexImage from "../../images/g-index.svg";
// import indexImage1 from "../../images/im1.jpeg";

const GroupIndex = () => {
  const [groups, setGroups] = useState([]);
  const [error, setError] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    setLoading(true);
    fetch("/groups.json", {
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/json"
      },
      credentials: "include",
    })
      .then(async (res) => {
        if (!res.ok) {
          const errorData = await res.json();
          throw new Error(errorData.message || 'Failed to fetch groups');
        }
        return res.json();
      })
      .then((data) => {
        if (data.message) {
          setGroups([]);
        } else {
          setGroups(Array.isArray(data) ? data : []);
        }
        setError(null);
      })
      .catch((error) => {
        console.error("Error fetching groups:", error);
        setError(error.message);
        setGroups([]);
      })
      .finally(() => {
        setLoading(false);
      });
  }, []);

  const handleDelete = async (groupId) => {
    if (!window.confirm("Are you sure you want to delete this group?")) {
      return;
    }
    
    const csrfToken = document.querySelector('meta[name="csrf-token"]')?.getAttribute('content');
    
    try {
      const response = await fetch(`/groups/${groupId}`, {
        method: 'DELETE',
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'X-CSRF-Token': csrfToken
        },
        credentials: 'include'
      });

      if (response.status === 204) { 
        setGroups(prevGroups => prevGroups.filter(group => group.id !== groupId));
        alert('Group successfully deleted');
        return;
      }

      let errorData;
      try {
        errorData = await response.json();
      } catch (e) {
        errorData = { error: 'An unexpected error occurred' };
      }

      if (response.status === 403) {
        alert('You are not authorized to delete this group');
      } else if (response.status === 404) {
        alert('Group not found');
      } else if (response.status === 500) {
        alert('A server error occurred. Please try again later.');
      } else {
        alert(errorData.error || 'Failed to delete the group');
      }
    } catch (error) {
      alert('An error occurred while trying to delete the group. Please try again.');
    }
  };

  return (
    <div className="group-index-wrapper">
      <div className="group-index-layout">
        <div className="group-index-container">
          <h1 className="group-index-title">My Celebrations</h1>
          <div className="space-y-4">
            {loading ? (
              <p className="text-center">Loading...</p>
            ) : error ? (
              <p className="text-red-600 text-center">{error}</p>
            ) : groups.length > 0 ? (
              groups.map((group) => (
                <div key={group.id} className="group-card">
                  <div>
                    <h5>
                      <a href={`/groups/${group.id}`} className="group-card-name">
                        {group.group_name}
                      </a>
                    </h5>
                
                    <a href={`/groups/group/${group.id}`} className="group-event-date">
                      <p><span>📅</span>
                        {new Date(group.event_date).toLocaleDateString("en-US", {
                          weekday: "long",
                          year: "numeric",
                          month: "long",
                          day: "numeric",
                        })}
                      </p>
                    </a>

                    <p className="group-participants">
                      Participants:{" "}
                      {group.participants && group.participants.length > 0
                        ? group.participants
                            .filter((participant) => participant.user)
                            .map((participant) => participant.user.name)
                            .join(", ")
                        : "No members"}
                    </p>
                  </div>

                  <button className="group-delete-button" onClick={() => handleDelete(group.id)}>
                    <FaTrashAlt size={16} />
                  </button>
                </div>
              ))
            ) : (
              <p className="text-gray-600 text-center">No celebrations found.</p>
            )}
          </div>
          <a href="/group_generator" className="group-create-button">
            Create a new group →
          </a>
        </div>

        <div className="group-index-image">
          <img 
            src={indexImage}
            alt="Gift Celebration"
            className="celebration-image"
          />
        </div>
      </div>

      <div className="floating-gifts">
        <div className="gift gift-1"></div>
        <div className="gift gift-2"></div>
        <div className="gift gift-3"></div>
        <div className="gift gift-4"></div>
        <div className="gift gift-5"></div>
        <div className="gift gift-6"></div>
      </div>
    </div>
  );
};

export default GroupIndex;
