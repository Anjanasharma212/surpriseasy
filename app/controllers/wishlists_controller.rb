class WishlistsController < ApplicationController
  before_action :set_participant, only: [:index, :create]
  before_action :set_wishlist, only: [:show, :update, :destroy]

  def index
    @wishlists = @participant.wishlists
    render json: @wishlists.map { |wishlist| 
      WishlistSerializer.new(wishlist).format_wishlist_details 
    }
  end

  def show
    authorize @wishlist
    render json: WishlistSerializer.new(@wishlist, current_user).format_wishlist_details
  end

  def create
    authorize Wishlist.new(participant: @participant)
    result = Wishlists::WishlistService.new(@participant)
                                     .create_with_items(wishlist_params)
    
    if result[:success]
      render json: result[:wishlist], status: :created
    else
      render_error(result[:error])
    end
  end

  def update
    authorize @wishlist
    result = Wishlists::WishlistService.new(@participant)
                                     .update_wishlist(@wishlist, wishlist_params)
    
    if result[:success]
      render json: result[:wishlist], status: :ok
    else
      render_error(result[:error])
    end
  end

  def destroy
    authorize @wishlist
    if @wishlist.destroy
      head :no_content
    else
      render_error(I18n.t('errors.deletion_failed'))
    end
  end

  private

  def set_participant
    @participant = Participant.find(params[:participant_id])
  end

  def set_wishlist
    @wishlist = Wishlist.includes(wishlist_items: :item).find(params[:id])
  end

  def wishlist_params
    params.require(:wishlist).permit(
      :participant_id,
      :group_id,
      wishlist_items_attributes: [:id, :item_id, :_destroy]
    )
  end
end
