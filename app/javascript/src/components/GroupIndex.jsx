import React, { useEffect, useState } from "react";
import { FaTrashAlt } from "react-icons/fa";
import indexImage from "../../images/g-index.svg";
// import indexImage1 from "../../images/im1.jpeg";

const GroupIndex = () => {
  const [groups, setGroups] = useState([]);

  useEffect(() => {
    fetch("/groups.json", {
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/json"
      },
      credentials: "include",
    })
      .then((res) => res.json())
      .then((data) => {
        setGroups(Array.isArray(data) ? data : []);
      })
      .catch((error) => console.error("Error fetching groups:", error));
  }, []);

  const handleDelete = async (groupId) => {
    if (!window.confirm("Are you sure you want to delete this group?")) {
      return;
    }
    const csrfToken = document.querySelector('meta[name="csrf-token"]')?.getAttribute('content');
    try {
      const response = await fetch(`/groups/${groupId}`, {
        method: "DELETE",
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
          'X-CSRF-Token': csrfToken
        },
        credentials: "include",
      });

      if (response.ok) {
        setGroups((prevGroups) => prevGroups.filter(group => group.id !== groupId));
      } else {
        const errorData = await response.json();
        alert(errorData.error || "Failed to delete the group.");
      }
    } catch (error) {
      console.error("Error deleting group:", error);
    }
  };

  return (
    <div className="group-index-wrapper">
      <div className="group-index-layout">
        <div className="group-index-container">
          <h1 className="group-index-title">My Celebrations</h1>
          <div className="space-y-4">
            {Array.isArray(groups) && groups.length > 0 ? (
              groups.map((group) => (
                <div key={group.id} className="group-card">
                  <div>
                    {/* <h2 className="text-blue-600 text-lg font-semibold">
                      {group.group_name}
                    </h2> */}

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
