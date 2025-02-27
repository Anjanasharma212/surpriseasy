class WishlistsController < ApplicationController
  before_action :set_participant, except: [:show]
  before_action :set_wishlist, only: [:show, :update]

  def show
    render json: WishlistSerializer.new(@wishlist).as_json
  end  

  def create
    @wishlist = Wishlist.new(wishlist_params)
    @wishlist.participant = @participant

    if @wishlist.save
      render json: {
        message: "Wishlist created successfully!",
        wishlist: WishlistSerializer.new(@wishlist).as_json
      }, status: :created
    else
      render json: { error: @wishlist.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if params[:wishlist] && params[:wishlist][:wishlist_items_attributes]
      existing_wishlist_items = @wishlist.wishlist_items.index_by(&:item_id)
  
      params[:wishlist][:wishlist_items_attributes].each do |item|
        item_id = item[:item_id].to_i
        if existing_wishlist_items[item_id]
          item[:id] = existing_wishlist_items[item_id].id
        end
      end
    end
  
    if @wishlist.update(wishlist_params)
      render json: {
        message: "Wishlist updated successfully!",
        wishlist: WishlistSerializer.new(@wishlist).as_json
      }, status: :ok
    else
      render json: { error: @wishlist.errors.full_messages }, status: :unprocessable_entity
    end
  end  

  private

  def set_participant
    @participant = if params[:participant_id]
      Participant.find_by(id: params[:participant_id])
    else
      Participant.find_by(user_id: current_user&.id)
    end
  end

  def set_wishlist
    @wishlist = Wishlist.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Wishlist not found" }, status: :not_found
  end

  def wishlist_params
    params.require(:wishlist).permit(
      :participant_id,
      :group_id,
      item_ids: [], 
      wishlist_items_attributes: [:id, :item_id, :_destroy]
    )
  end  
end
