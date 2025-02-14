class ItemsController < ApplicationController
  def index 
    items = Item.all
    items = items.where(category: params[:category]) if params[:category].present?
    items = items.where(age: params[:age]) if params[:age].present?
    items = items.where(gender: params[:gender]) if params[:gender].present?
  
    if params[:minPrice].present? && params[:maxPrice].present?
      items = items.where("price >= ? AND price <= ?", params[:minPrice].to_i, params[:maxPrice].to_i)
    elsif params[:minPrice].present?
      items = items.where("price >= ?", params[:minPrice].to_i)   
    elsif params[:maxPrice].present?
      items = items.where("price <= ?", params[:maxPrice].to_i)
    end
    
    # Items Searching 
    if params[:search].present?
      search_item = "%#{params[:search]}%"
      items = items.where("item_name ILIKE ? OR price::TEXT ILIKE ?", search_item, search_item)
      # items = items.where("LOWER(item_name) LIKE ? OR CAST(price AS TEXT) LIKE ?", search_item, search_item)
    end 
    
    respond_to do |format|
      format.html
      format.json { render json: items }
    end
  end
  
  def filters
    filters = {
      categories: Item.distinct.pluck(:category),
      ages: Item.distinct.pluck(:age),
      genders: Item.distinct.pluck(:gender),
    }  
    render json: filters
  end  
end
