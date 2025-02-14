import React, { useEffect, useState } from "react";
import { FaTrashAlt } from "react-icons/fa";

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
  console.log(groups);

  return (
    <div className="group-index-container">
    <h1 className="group-index-title">My Celebrations</h1>

  <div className="space-y-4">
    {Array.isArray(groups) && groups.length > 0 ? (
      groups.map((group) => (
        <div key={group.id} className="group-card">
          <div>
            <h2 className="text-blue-600 text-lg font-semibold">
              {group.name}
            </h2>

            <h5>
              <a href={`/groups/${group.id}`} className="group-card-name">
                {group.group_name}
              </a>
            </h5>

            <a href={`/groups/group/${group.id}`} className="group-event-date">
              <p>Event Date:{" "}
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

          <button className="group-delete-button">
            <FaTrashAlt size={16} />
          </button>
        </div>
      ))
    ) : (
      <p className="text-gray-600 text-center">No celebrations found.</p>
    )}
  </div>

  <a href="/gift-generator" className="group-create-button">
    Create a new group →
  </a>
</div>

  );
};

export default GroupIndex;
