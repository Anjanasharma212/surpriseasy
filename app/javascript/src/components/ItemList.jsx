import React, { useEffect, useState } from "react";
import FilterBar from "./FilterBar";
import { FaSearch } from "react-icons/fa";
import { useParams } from 'react-router-dom';

const ItemList = () => {
  const { id } = useParams();
  const [items, setItems] = useState([]);
  const [wishlist, setWishList] = useState([]);
  const [searchQuery, setSearchQuery] = useState("");

  useEffect(() => {
    fetch("http://localhost:3000/items.json")
      .then((response) => response.json())
      .then((data) => setItems(data))
      .catch((error) => console.error("Fetch error:", error));
  }, []);

  useEffect(() => {
    fetch(`http://localhost:3000/wishlists/${id}`)
      .then((response) => response.json())
      .then((data) => {
        if (data.items) setWishList(data.items); 
      })
      .catch((error) => console.error("Error fetching wishlist:", error));
  }, [id]);
  
  useEffect(() => {
    const savedWishlist = localStorage.getItem("wishlist");
    if (savedWishlist) {
      setWishList(JSON.parse(savedWishlist));
    }
  }, []);

  const toggleWishlist = (item) => {
    let updatedWishlist;
    if (wishlist.some((wishItem) => wishItem.id === item.id)) {
      updatedWishlist = wishlist.filter((wishItem) => wishItem.id !== item.id);
    } else {
      updatedWishlist = [...wishlist, item];
    }
    setWishList(updatedWishlist);
    localStorage.setItem("wishlist", JSON.stringify(updatedWishlist));
  };  
  
  const saveWishlist = () => {
    const csrfToken = document.querySelector('meta[name="csrf-token"]').getAttribute("content");

    fetch("http://localhost:3000/wishlists", {
      method: "POST",
      headers: {
        "Content-Type": "application/json", 
        "X-CSRF-Token": csrfToken 
      },
      body: JSON.stringify({ item_ids: wishlist.map((item) => item.id) }),
    })
      .then((response) => response.json())
      .then((data) => alert("Wishlist saved successfully!"))
      .catch((error) => console.error("Error saving wishlist:", error));
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
      <div className="item-card">
        {/* Search Section */}
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

        {/* Items Grid */}
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
        <h3>My Wishlist</h3>
        {wishlist.length > 0 ? (
          <>
            <div className="wishlist-items">
              {wishlist.map((item) => (
                <div key={item.id} className="wishlist-item">
                  <img src={item.image_url} alt={item.item_name} className="wishlist-image" />
                  <p className="item-name">{item.item_name}</p>
                  <button className="remove-btn" onClick={() => toggleWishlist(item)}>
                    Remove
                  </button>
                </div>
              ))}
            </div>
            <button className="save-btn" onClick={saveWishlist}>
              Save Wishlist
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
    </div>
  );
};

export default ItemList;
