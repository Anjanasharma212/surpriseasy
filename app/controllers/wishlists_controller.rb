class WishlistsController < ApplicationController
  before_action :set_participant

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
    unless @participant
      render json: { error: "Participant not found" }, status: :not_found
    end
  end
end
