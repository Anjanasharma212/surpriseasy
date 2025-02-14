import React, { useState, useEffect } from "react";
import Select from "react-select";
import axios from "axios";

const FilterBar = ({ setItems }) => {
  const [filters, setFilters] = useState({
    category: [],
    minPrice: "",
    maxPrice: "",
    age: [],
    gender: [],
  });

  const [filterOptions, setFilterOptions] = useState({
    categories: [],
    ages: [],
    genders: [],
  });
  
  const [isPriceModalOpen, setPriceModalOpen] = useState(false);

  useEffect(() => {
    axios.get("http://localhost:3000/items/filters") 
      .then(response => setFilterOptions(response.data))
      .catch(error => console.error("Error fetching filters:", error));
  }, []); 

  const applyFilters = () => {
    let filterParams = { ...filters };
    
    axios.get("http://localhost:3000/items.json", { params: filterParams }) 
      .then(response => setItems(response.data))
      .catch(error => console.error("Error fetching items:", error));
  };

  useEffect(() => {
    const allFiltersEmpty = Object.values(filters).every(filter => filter.length === 0);
    if (allFiltersEmpty) {
      applyFilters();
    }
  }, [filters]);

  return (
    <div className="filter-bar">
      <Select
        options={filterOptions.categories.map(cat => ({ value: cat, label: cat }))}
        isMulti
        placeholder="Category"
        value={filters.category.map(cat => ({ value: cat, label: cat }))} 
        onChange={(selected) => setFilters(prev => ({
          ...prev,
          category: selected ? selected.map(option => option.value) : [],
        }))}
      />

      <Select
        options={[]}
        placeholder={filters.minPrice && filters.maxPrice ? `$${filters.minPrice} - $${filters.maxPrice}` : "Price"}
        onMenuOpen={() => setPriceModalOpen(true)}
      />

      {isPriceModalOpen && (
        <div className="modal-overlay">
          <div className="modal-content">
            <h3>Select Price Range</h3>
            <div className="price-inputs">
              <input
                type="number"
                placeholder="Min Price"
                value={filters.minPrice}
                onChange={(e) => setFilters(prev => ({ ...prev, minPrice: e.target.value }))}
              />
              <input
                type="number"
                placeholder="Max Price"
                value={filters.maxPrice}
                onChange={(e) => setFilters(prev => ({ ...prev, maxPrice: e.target.value }))}
              />
            </div>
            <div className="modal-actions">
              <button onClick={() => setPriceModalOpen(false)}>Cancel</button>
              <button onClick={() => setPriceModalOpen(false)}>Apply</button>
            </div>
          </div>
        </div>
      )}

      <Select
        options={filterOptions.ages.map(age => ({ value: age, label: age }))}
        isMulti
        placeholder="Age"
        value={filters.age.map(age => ({ value: age, label: age }))}
        onChange={(selected) => setFilters(prev => ({
          ...prev,
          age: selected ? selected.map(option => option.value) : [],
        }))}
      />

      <Select
        options={filterOptions.genders.map(gender => ({ value: gender, label: gender }))}
        isMulti
        placeholder="Gender"
        value={filters.gender.map(gender => ({ value: gender, label: gender }))}
        onChange={(selected) => setFilters(prev => ({
          ...prev,
          gender: selected ? selected.map(option => option.value) : [],
        }))}
      />

      <button className="filter-button" onClick={applyFilters}>Apply Filters</button>
      <button 
        className="filter-button" 
        onClick={() => setFilters({ category: [], minPrice: "", maxPrice: "", age: [], gender: [] })}
      >
        Clear Filters
      </button>
    </div>
  );
};

export default FilterBar;
