class ItemsController < ApplicationController
  def index 
    @items = Item.all
    
    ['category', 'age', 'gender', 'price_range', 'search'].each do |filter_criteria|
      @items = @items.send("by_#{filter_criteria}", *filter_params(filter_criteria))
    end
    
    respond_to do |format|
      format.html
      format.json { render json: @items }
    end
  end
  
  def filters
    render json: Item.fetch_distinct_filters
  end

  private

  def filter_params(criteria)
    case criteria
    when 'price_range'
      [params[:minPrice], params[:maxPrice]]
    when 'search'
      [params[:search]]
    else
      [params[criteria]]
    end
  end
end
