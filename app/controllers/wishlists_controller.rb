class WishlistsController < ApplicationController
  before_action :set_participant
  before_action :set_wishlist, only: [:show]

  def show
    respond_to do |format|
      format.html
      format.json do
        render json: {
          participant_id: @participant.id,
          wishlist_id: @wishlist.id,
          items: @wishlist.items.as_json(only: [:id, :name, :description, :image_url])
        }
      end
    end
  end  

  def create
    @wishlist = Wishlist.create!(participant: @participant)  
    item_ids = params[:item_ids] || []

    item_ids.each do |item_id|
      WishlistItem.create!(wishlist: @wishlist, item_id: item_id)
    end

    render json: { message: "Wishlist created successfully!", wishlist: @wishlist }, status: :created
  rescue ActiveRecord::RecordInvalid => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  private

  def set_participant
    @participant = Participant.find_by(id: params[:participant_id])
    # @participant = Participant.find_by(user_id: current_user.id)
    unless @participant
      render json: { error: "Participant not found" }, status: :not_found
    end
  end

  def set_wishlist
    @wishlist = @participant.wishlists.find_by(id: params[:id])
    render json: { error: "Wishlist not found" }, status: :not_found unless @wishlist
  end
end
