class WishlistsController < ApplicationController
  before_action :set_wishlist, only: [:show, :update, :destroy]
  before_action :authorize_wishlist_access, only: [:show, :update, :destroy]

  def index
    @wishlists = current_user.wishlists
    render json: @wishlists.map { |wishlist| WishlistSerializer.new(wishlist).format_wishlist_details }
  end

  def show
    render json: WishlistSerializer.new(@wishlist).format_wishlist_details
  end

  def create
    @wishlist = Wishlist.new(wishlist_params)

    if @wishlist.save
      render json: WishlistSerializer.new(@wishlist).format_wishlist_details, status: :created
    else
      render_error("Failed to create wishlist", :unprocessable_entity)
    end
  end

  def update
    if update_wishlist_items
      render json: WishlistSerializer.new(@wishlist.reload).format_wishlist_details
    else
      render_error("Failed to update wishlist", :unprocessable_entity)
    end
  end

  def destroy
    if @wishlist.destroy
      head :no_content
    else
      render_error("Failed to delete wishlist", :unprocessable_entity)
    end
  end

  private

  def set_wishlist
    @wishlist = Wishlist.includes(wishlist_items: :item).find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_error("Wishlist not found", :not_found)
  end

  def authorize_wishlist_access
    unless @wishlist.participant.user == current_user
      render_error("You are not authorized to access this wishlist", :forbidden)
    end
  end

  def wishlist_params
    params.require(:wishlist).permit(
      :participant_id,
      :group_id,
      wishlist_items_attributes: [:id, :item_id, :_destroy]
    )
  end

  def update_wishlist_items
    ActiveRecord::Base.transaction do
      remove_items if items_to_remove.any?
      add_new_items if new_items.any?
      true
    end
  rescue StandardError => e
    Rails.logger.error("Error updating wishlist: #{e.message}")
    false
  end

  def remove_items
    items_to_remove.each do |item|
      @wishlist.wishlist_items.find(item[:id]).destroy
    end
  end

  def add_new_items
    existing_item_ids = @wishlist.wishlist_items.pluck(:item_id)
    
    new_items.each do |item|
      next if existing_item_ids.include?(item[:item_id].to_i)
      @wishlist.wishlist_items.create(item_id: item[:item_id])
    end
  end

  def items_to_remove
    @items_to_remove ||= wishlist_items_attributes.select { |item| item[:_destroy] && item[:id] }
  end

  def new_items
    @new_items ||= wishlist_items_attributes.reject { |item| item[:_destroy] || item[:id] }
  end

  def wishlist_items_attributes
    params.dig(:wishlist, :wishlist_items_attributes) || []
  end

  def render_error(message, status)
    render json: { error: message }, status: status
  end
end
