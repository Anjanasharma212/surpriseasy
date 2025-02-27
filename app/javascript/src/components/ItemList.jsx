import React, { useEffect, useState } from "react";
import FilterBar from "./FilterBar";
import { FaSearch } from "react-icons/fa";
import { useParams } from 'react-router-dom';

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

  useEffect(() => {
    const loadData = async () => {
      try {
        setIsLoading(true);
  
        const itemsResponse = await fetch("/items.json");
        const itemsData = await itemsResponse.json();
        setItems(itemsData);
  
        if (groupId) {
          const groupResponse = await fetch(`/groups/${groupId}.json`);
          const groupData = await groupResponse.json();
  
          if (groupData.logged_in_participant) {
            setParticipantId(groupData.logged_in_participant.id);
  
            const wishlistIdToFetch = wishlistId || groupData.logged_in_participant.wishlist_id;
  
            if (wishlistIdToFetch) {
              console.log("🔍 Fetching Wishlist with ID:", wishlistIdToFetch);
              const wishlistResponse = await fetch(`/wishlists/${wishlistIdToFetch}.json`);
              const wishlistData = await wishlistResponse.json();
  
              console.log("🔍 Wishlist Data from API:", wishlistData);
  
              if (wishlistData.items) {
                setWishList(
                  wishlistData.items.map(item => ({
                    ...item,
                    wishlist_item_id: item.wishlist_item_id || item.id
                  }))
                );
                setWishlistId(wishlistData.id);
              }
            }
          }
        }
      } catch (error) {
        console.error("❌ Error loading data:", error);
      } finally {
        setIsLoading(false);
      }
    };
  
    loadData();
  }, [groupId, wishlistId]); 
  
  const handleRemove = async (item) => {
    const updatedWishlist = wishlist.filter((wishItem) => wishItem.id !== item.id);
    setWishList(updatedWishlist);
  
    try {
      const csrfToken = document.querySelector('meta[name="csrf-token"]').getAttribute("content");
  
      const response = await fetch(`/wishlists/${wishlistId}`, {
        method: "PATCH",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": csrfToken,
        },
        body: JSON.stringify({
          wishlist: { 
            item_ids: updatedWishlist.map(item => item.id),
            participant_id: participantId,
            group_id: groupId
          }
        }),
      });
  
      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }
  
      const data = await response.json();
  
      if (data.error) {
        alert(data.error);
      } else {
        setWishList(data.wishlist.items || []);
        alert("Wishlist updated successfully!");
      }
    } catch (error) {
      console.error("Error updating wishlist:", error);
      alert("Failed to update wishlist. Please try again.");
    }
  };
  
  
  const toggleWishlist = (item) => {
    console.log('Toggle wishlist for item:', item);
    
    setWishList(currentWishlist => {
      const isItemInWishlist = currentWishlist.some(wishItem => wishItem.id === item.id);
      let updatedWishlist;
      
      if (isItemInWishlist) {
        updatedWishlist = currentWishlist.filter(wishItem => wishItem.id !== item.id);
      } else {
        updatedWishlist = [...currentWishlist, item];
      }
      return updatedWishlist;
    });

    setItems(currentItems => {
      return currentItems.map(listItem => ({
        ...listItem,
        isInWishlist: listItem.id === item.id ? !listItem.isInWishlist : listItem.isInWishlist
      }));
    });
  };

  const saveWishlist = async () => {
    try {
      const csrfToken = document.querySelector('meta[name="csrf-token"]').getAttribute("content");
      const url = wishlistId ? `/wishlists/${wishlistId}` : "/wishlists";
      const method = wishlistId ? "PATCH" : "POST";
  
      const wishlistItems = wishlist.map(item => ({
        id: item.wishlist_item_id || undefined,
        item_id: item.id
      })).filter(item => item.item_id);
  
      const response = await fetch(url, {
        method: method,
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": csrfToken
        },
        body: JSON.stringify({
          wishlist: {
            wishlist_items_attributes: wishlistItems
          }
        }),
      });
  
      if (!response.ok) throw new Error(`HTTP error! status: ${response.status}`);
  
      const data = await response.json();
      if (data.error) {
        alert(data.error);
      } else {
        if (!wishlistId) setWishlistId(data.wishlist.id);

        const updatedWishlistResponse = await fetch(`/wishlists/${data.wishlist.id}.json`);
        const updatedWishlist = await updatedWishlistResponse.json();
        
        setWishList(updatedWishlist.items);
        alert(data.message);
      }
    } catch (error) {
      console.error("Error saving wishlist:", error);
      alert("Failed to save wishlist. Please try again.");
    }
  };

  const fetchItems = () => {
    fetch(`http://localhost:3000/items.json?search=${searchQuery}`)
      .then((response) => response.json())
      .then((data) => {
        setItems(data)
      })
      .catch((error) => console.error("Error fetching items:", error));
  };
  
  const handleSearch = () => {
    if (searchQuery.trim() !== "") {
      fetchItems();
    }
  };
  
  return (
    <div className="main-container">
      {isLoading ? (
        <div>Loading...</div>
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
                      <button
                        className={`wishlist-btn ${
                          wishlist.some((w) => w.id === item.id) ? "added" : ""
                        }`}
                        onClick={() => toggleWishlist(item)}
                      >
                        {wishlist.some((w) => w.id === item.id) ? "❤️" : "🤍"}
                      </button>
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

          {/* Wishlist Section */}
          <div className="wishlist-card">
            <h3>{wishlistId ? 'Update My Wishlist' : 'Create My Wishlist'}</h3>
            {wishlist.length > 0 ? (
              <>
                <div className="wishlist-items">
                  {wishlist.map((item) => (
                    <div key={item.id} className="wishlist-item">
                      <img src={item.image_url} alt={item.item_name} className="wishlist-image" />
                      <p className="item-name">{item.item_name}</p>
                      <button 
                        className="remove-btn" 
                        onClick={() => handleRemove(item)}
                      >
                        Remove
                      </button>
                    </div>
                  ))}
                </div>
                <button className="save-btn" onClick={saveWishlist}>
                  {wishlistId ? 'Update Wishlist' : 'Save Wishlist'}
                </button>
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
