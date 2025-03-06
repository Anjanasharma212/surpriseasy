module Wishlists
  class WishlistService

    def initialize(participant)
      @participant = participant
    end

    def create_with_items(params)
      items_to_create = if params[:item_ids].present?
                         params[:item_ids].map { |id| { item_id: id } }
                       else
                         params[:wishlist_items_attributes]
                       end

      validate_items(items_to_create)

      ActiveRecord::Base.transaction do
        wishlist = @participant.wishlists.create!
        
        create_wishlist_items(wishlist, items_to_create)

        success_response(wishlist)
      end
    rescue ActiveRecord::RecordInvalid => e
      failure_response(e.message)
    rescue StandardError => e
      failure_response(I18n.t('wishlists.errors.creation_failed'))
    end

    def update_wishlist(wishlist, params)
      ActiveRecord::Base.transaction do
        validate_items(params[:wishlist_items_attributes]) if params[:wishlist_items_attributes].present?
        
        if wishlist.update(params)
          success_response(wishlist.reload)
        else
          failure_response(wishlist.errors.full_messages.join(", "))
        end
      end
    rescue StandardError => e
      failure_response(e.message)
    end

    def destroy_wishlist(wishlist)
      if wishlist.destroy
        { success: true }
      else
        failure_response(I18n.t('wishlists.errors.deletion_failed'))
      end
    end

    private

    def validate_items(items_attributes)
      return if items_attributes.blank?

      item_ids = items_attributes.map { |attr| attr[:item_id] || attr }
      existing_items = Item.where(id: item_ids)
      
      missing_items = item_ids - existing_items.pluck(:id)
      if missing_items.any?
        raise StandardError, I18n.t('wishlists.errors.invalid_items', 
                                   items: missing_items.join(', '))
      end
    end

    def create_wishlist_items(wishlist, items_attributes)
      items_attributes.each do |item_attr|
        item_id = item_attr.is_a?(Hash) ? item_attr[:item_id] : item_attr
        wishlist.wishlist_items.create!(item_id: item_id)
      end
    end

    def success_response(wishlist)
      {
        success: true,
        wishlist: WishlistSerializer.new(wishlist).format_wishlist_details
      }
    end

    def failure_response(error_message)
      {
        success: false,
        error: error_message
      }
    end
  end
end 