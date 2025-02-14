import React, { useEffect, useState } from 'react';
import { Card, Button } from 'react-bootstrap';

const GroupDetails = ({ groupId }) => {
  const [groupDetails, setGroupDetails] = useState(null);

  useEffect(() => {
    fetch(`/groups/${groupId}`, {
      headers: {
        'Authorization': `Bearer ${localStorage.getItem('token')}`,
      },
    })
      .then(response => response.json())
      .then(data => setGroupDetails(data))
      .catch(error => console.error('Error fetching group details:', error));
  }, [groupId]);

  if (!groupDetails) {
    return <div>Loading...</div>;
  }

  return (
    <Card className="shadow-sm p-4 rounded-4">
      <Card.Img
        variant="top"
        src="https://static-cdn.drawnames.com/Content/Assets/gifts-valentine.svg?nc=202407011621"
        alt="gifts"
        className="img-fluid mb-3"
      />
      <Card.Body>
        <Card.Title className="fs-3 fw-bold">
          {groupDetails.group_name}
        </Card.Title>
        <Card.Text className="text-muted">
          Hi {groupDetails.user_email}, good to see you again!
        </Card.Text>
        <div className="d-flex flex-column gap-2">
          <Button variant="primary" href="#">
            {new Date(groupDetails.event_date).toDateString()}
          </Button>
          <Button variant="primary" href="#">
            gift amount: {groupDetails.amount}
          </Button>
        </div>
      </Card.Body>
    </Card>
  );
};

export default GroupDetails;
