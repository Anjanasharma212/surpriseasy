class WishlistsController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :handle_not_found
  rescue_from StandardError, with: :render_error

  before_action :set_participant
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
    result = Wishlists::WishlistService.new(@participant)
                                     .create_with_items(wishlist_params[:wishlist_items_attributes])
    
    if result[:success]
      render json: result[:wishlist], status: :created
    else
      render_error(result[:error])
    end
  end

  def update
    ActiveRecord::Base.transaction do
      if @wishlist.update(wishlist_params)
        render json: WishlistSerializer.new(@wishlist.reload).format_wishlist_details
      else
        render_error(@wishlist.errors.full_messages.join(", "))
      end
    end
  rescue StandardError => e
    render_error(e.message)
  end

  def destroy
    @wishlist.destroy!
    head :no_content
  rescue StandardError => e
    render_error(e.message)
  end

  private

  def set_participant
    @participant = if params[:participant_id]
      Participant.find(params[:participant_id])
    else
      @wishlist = Wishlist.find(params[:id])
      @wishlist.participant
    end
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

  def user_not_authorized
    render json: { error: I18n.t('wishlists.errors.unauthorized') }, 
           status: :forbidden
  end

  def handle_not_found
    render json: { error: I18n.t('errors.record_not_found') }, 
           status: :not_found
  end

  def render_error(message)
    render json: { error: message }, 
           status: :unprocessable_entity
  end
end
