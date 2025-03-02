import React, { useState, useEffect } from "react";

const WishlistShow = () => {
  const pathSegments = window.location.pathname.split("/").filter(Boolean);

  const groupIndex = pathSegments.indexOf("groups");
  const participantIndex = pathSegments.indexOf("participants");
  const wishlistIndex = pathSegments.indexOf("wishlists");

  const group_id = groupIndex !== -1 ? pathSegments[groupIndex + 1] : null;
  const participant_id = participantIndex !== -1 ? pathSegments[participantIndex + 1] : null;
  const wishlist_id = wishlistIndex !== -1 ? pathSegments[wishlistIndex + 1] : null;

  const [wishlist, setWishlist] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    if (!wishlist_id || !participant_id) return;

    fetch(`/participants/${participant_id}/wishlists/${wishlist_id}.json`)
      .then((res) => {
        if (!res.ok) {
          throw new Error(res.status === 422 ? "Unauthorized access" : "Failed to fetch wishlist");
        }
        return res.json();
      })
      .then((data) => {
        setWishlist(data.wishlist);
        setLoading(false);
      })
      .catch((err) => {
        setError(err.message);
        setLoading(false);
      });
  }, [participant_id, wishlist_id]);

  if (loading) return <div className="text-center py-5">Loading wishlist...</div>;
  if (error) return <div className="text-center text-danger py-5">Error: {error}</div>;
  if (!wishlist || !wishlist.items || wishlist.items.length === 0)
    return <div className="text-center py-5">No items found in this wishlist.</div>;

  return (
    <div className="container py-5">
      <div className="row">
        {wishlist.items.map((item) => (
          <div key={item.id} className="col-md-4 mb-4">
            <div className="card shadow-sm p-3 h-100">
              <img
                src={item.image_url || "https://via.placeholder.com/200"}
                alt={item.item_name}
                className="img-fluid rounded"
                style={{ height: "200px", objectFit: "cover" }}
              />
              <div className="card-body d-flex flex-column">
                <h5 className="card-title">{item.item_name}</h5>
                <p className="text-muted">{item.description}</p>
                <p className="text-primary">${item.price}</p>
                <button className="btn btn-primary mt-auto">View Details</button>
              </div>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
};

export default WishlistShow;
  