class WishlistSerializer
  def initialize(wishlist, user = nil)
    @wishlist = wishlist
    @user = user
  end

  def format_wishlist_details
    {
      wishlist: {
        id: @wishlist.id,
        participant_id: @wishlist.participant_id,
        group_id: @wishlist.group_id,
        items: format_items,
        is_owner: is_owner?
      }
    }
  end

  private

  def format_items
    @wishlist.wishlist_items.map do |wishlist_item|
      {
        id: wishlist_item.item.id,
        item_name: wishlist_item.item.item_name,
        price: wishlist_item.item.price,
        description: wishlist_item.item.description,
        image_url: wishlist_item.item.image_url,
        wishlist_item_id: wishlist_item.id
      }
    end
  end

  def is_owner?
    @wishlist.participant.user_id == @user&.id
  end
end
