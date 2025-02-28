class ItemsController < ApplicationController
  def index 
    items = Item.all
      .by_category(params[:category])
      .by_age(params[:age])
      .by_gender(params[:gender])
      .by_price_range(params[:minPrice], params[:maxPrice])
      .by_search(params[:search])
    
    respond_to do |format|
      format.html
      format.json { render json: items }
    end
  end
  
  def filters
    render json: Item.fetch_distinct_filters
  end  
end
