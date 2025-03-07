import React, { useEffect, useState } from "react";
import FilterBar from "./FilterBar";
import { FaSearch } from "react-icons/fa";
import { useParams } from 'react-router-dom';
import { debounce } from 'lodash';

const ItemList = () => {
  const params = new URLSearchParams(window.location.search);
  const groupId = params.get('group_id');
  const wishlistIdParam = params.get('wishlist_id');
  
  const [items, setItems] = useState([]);
  const [wishlist, setWishList] = useState([]);
  const [searchQuery, setSearchQuery] = useState("");
  const [wishlistId, setWishlistId] = useState(wishlistIdParam);
  const [participantId, setParticipantId] = useState(null);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState(null);
  const [isOwner, setIsOwner] = useState(false);

  useEffect(() => {
    const loadData = async () => {
      try {
        setIsLoading(true);
        setError(null);
        const itemsResponse = await fetch("/items.json");
        if (!itemsResponse.ok) throw new Error("Failed to fetch items");
        const itemsData = await itemsResponse.json();
        setItems(itemsData);

        if (groupId) {
          const groupResponse = await fetch(`/groups/${groupId}.json`);
          if (!groupResponse.ok) throw new Error("Failed to fetch group");
          const groupData = await groupResponse.json();

          if (groupData.logged_in_participant) {
            setParticipantId(groupData.logged_in_participant.id);
            const wishlistIdToFetch = wishlistIdParam || groupData.logged_in_participant.wishlist_id;

            if (wishlistIdToFetch) {
              const wishlistResponse = await fetch(`/wishlists/${wishlistIdToFetch}.json`);
              if (!wishlistResponse.ok) {
                console.error('Wishlist Response:', wishlistResponse.status);
                throw new Error("Failed to fetch wishlist");
              }
              const wishlistData = await wishlistResponse.json();
              
              setIsOwner(wishlistData.wishlist?.is_owner || false);

              const wishlistItems = wishlistData.wishlist?.items || [];
              setWishList(wishlistItems.map(item => ({
                ...item,
                wishlist_item_id: item.wishlist_item_id || item.id
              })));
              setWishlistId(wishlistData.wishlist?.id);
            }
          }
        }
      } catch (error) {
        console.error("Error loading data:", error);
        setError(error.message);
      } finally {
        setIsLoading(false);
      }
    };

    loadData();
  }, [groupId, wishlistIdParam]);

  const handleRemove = async (item) => {
    if (!wishlistId) {
      console.error("No wishlist ID available");
      return;
    }

    try {
      const updatedWishlist = wishlist.filter((wishItem) => wishItem.id !== item.id);

      const csrfToken = document.querySelector('meta[name="csrf-token"]')?.getAttribute("content");
      if (!csrfToken) throw new Error("CSRF token not found");

      const response = await fetch(`/wishlists/${wishlistId}`, {
        method: "PATCH",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": csrfToken,
        },
        body: JSON.stringify({
          wishlist: {
            wishlist_items_attributes: [{
              id: item.wishlist_item_id,
              _destroy: true
            }]
          }
        }),
      });

      if (!response.ok) {
        const errorData = await response.json();
        throw new Error(errorData.error || "Failed to remove item");
      }

      const data = await response.json();
      setWishList(updatedWishlist);
    } catch (error) {
      console.error("Error removing item:", error);
      alert(error.message || "Failed to remove item");
    }
  };

  const toggleWishlist = async (item) => {
    const isItemInWishlist = wishlist.some(wishItem => wishItem.id === item.id);

    if (isItemInWishlist) {
      const wishlistItem = wishlist.find(w => w.id === item.id);
      if (wishlistItem) {
        await handleRemove(wishlistItem);
      }
    } else {

      setWishList(currentWishlist => [
        ...currentWishlist,
        { ...item, wishlist_item_id: undefined }
      ]);
    }
  };

  const saveWishlist = async () => {
    try {
      const csrfToken = document.querySelector('meta[name="csrf-token"]')?.getAttribute("content");
      if (!csrfToken) throw new Error("CSRF token not found");

      if (!wishlist || wishlist.length === 0) {
        throw new Error("Please add items to your wishlist before saving");
      }

      const url = wishlistId ? `/wishlists/${wishlistId}` : "/wishlists";
      const method = wishlistId ? "PATCH" : "POST";

      const wishlistData = {
        wishlist: {
          participant_id: participantId,
          group_id: groupId,
          wishlist_items_attributes: wishlist.map(item => ({
            id: item.wishlist_item_id,
            item_id: item.id
          }))
        }
      };

      const response = await fetch(url, {
        method,
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": csrfToken
        },
        body: JSON.stringify(wishlistData),
      });

      if (!response.ok) {
        const errorData = await response.json();
        throw new Error(errorData.error || "Failed to save wishlist");
      }

      const data = await response.json();
      if (!data || !data.wishlist) {
        throw new Error("Invalid response format from server");
      }

      setWishlistId(data.wishlist.id);
      
      const newItems = data.wishlist.items || [];
      setWishList(newItems.map(item => ({
        ...item,
        wishlist_item_id: item.wishlist_item_id || item.id
      })));

      alert("Wishlist saved successfully!");
    } catch (error) {
      console.error("Error saving wishlist:", error);
      alert(error.message || "Failed to save wishlist");
    }
  };

  const fetchItems = () => {
    const searchParams = new URLSearchParams();

    if (searchQuery.trim()) {
      searchParams.set('search', searchQuery.trim());
    }

    if (params.category) searchParams.set('category', params.category);
    if (params.age) searchParams.set('age', params.age);
    if (params.gender) searchParams.set('gender', params.gender);
    if (params.minPrice) searchParams.set('minPrice', params.minPrice);
    if (params.maxPrice) searchParams.set('maxPrice', params.maxPrice);

    fetch(`/items.json?${searchParams}`)
      .then((response) => response.json())
      .then((data) => setItems(data))
      .catch((error) => console.error("Error fetching items:", error));
  };

  const handleSearch = debounce(() => {
    fetchItems();
  }, 300);

  useEffect(() => {
    fetchItems();
  }, []); 
  
  return (
    <div className="main-container">
      {isLoading ? (
        <div>Loading...</div>
      ) : error ? (
        <div className="error-message">{error}</div>
      ) : (
        <>
          <div className="item-card">
            <div className="search-container">
              <input
                type="text"
                placeholder="Search for gifts..."
                className="filter-input"
                value={searchQuery}
                onChange={(e) => {
                  const updatedQuery = e.target.value;
                  setSearchQuery(updatedQuery);
                  handleSearch(updatedQuery);
                }}
              />
              <button className="search-btn" onClick={handleSearch}>
                <FaSearch />
              </button>
            </div>

            {/* Filter Section */}
            <FilterBar setItems={setItems} />

            <div className="item-row">
              {items.length > 0 ? (
                items.map((item) => (
                  <div key={item.id} className="item">
                    <img src={item.image_url} alt={item.item_name} className="item-image" />
                    <div className="item-details">
                      <h3 className="item-name">{item.item_name}</h3>
                      <p className="item-price">
                        ${typeof item.price === 'number' ? item.price.toFixed(2) : item.price}
                      </p>
                      <p className="item-description">{item.description}</p>
                      {isOwner && (
                        <button
                          className={`wishlist-btn ${
                            wishlist.some((w) => w.id === item.id) ? "added" : ""
                          }`}
                          onClick={() => toggleWishlist(item)}
                        >
                          {wishlist.some((w) => w.id === item.id) ? "❤️" : "🤍"}
                        </button>
                      )}
                    </div>
                  </div>
                ))
              ) : (
                <div className="no-items">
                  <p>No items found matching your criteria.</p>
                </div>
              )}
            </div>
          </div>


          <div className="wishlist-card">
            <h3>
              {wishlistId ? 'My Wishlist' : 'Create My Wishlist'}
            </h3>
            {wishlist.length > 0 ? (
              <>
                <div className="wishlist-items">
                  {wishlist.map((item) => (
                    <div key={item.id} className="wishlist-item">
                      <img src={item.image_url} alt={item.item_name} className="wishlist-image" />
                      <div className="wishlist-item-details">
                        <p className="item-name">{item.item_name}</p>
                        <p className="item-price">${item.price}</p>
                      </div>
                      {isOwner && (
                        <button 
                          className="remove-btn" 
                          onClick={() => handleRemove(item)}
                        >
                          Remove
                        </button>
                      )}
                    </div>
                  ))}
                </div>
                <div className="wishlist-actions">
                  {isOwner && (
                    <button className="save-btn" onClick={saveWishlist}>
                      {!wishlistId || wishlist.some(item => !item.wishlist_item_id) 
                        ? 'Make a Wish List' 
                        : 'Update Wishlist'
                      }
                    </button>
                  )}
                  {wishlistId && (
                    <a href={`/groups/${groupId}`} className="back-btn">
                      Back to Group
                    </a>
                  )}
                </div>
              </>
            ) : (
              <div className="wishlist-placeholder">
                <img
                  src="https://static-cdn.drawnames.com/Content/Assets/placeholder-wishlist-gift.svg"
                  alt="Empty wishlist"
                  className="wishlist-image"
                />
                <div className="wishlist-text">
                  <p>Your wishlist is empty</p>
                  <p>Add items by clicking the heart icon</p>
                </div>
              </div>
            )}
          </div>
        </>
      )}
    </div>
  );
};

export default ItemList;
