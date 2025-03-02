class WishlistSerializer
  def initialize(wishlist)
    @wishlist = wishlist
  end

  def format_wishlist_details
    {
      wishlist: {
        id: @wishlist.id,
        participant_id: @wishlist.participant_id,
        group_id: @wishlist.participant&.group_id,
        items: format_items
      }
    }
  end

  private

  def format_items
    @wishlist.wishlist_items.map do |wishlist_item|
      {
        id: wishlist_item.item.id,
        wishlist_item_id: wishlist_item.id,
        item_name: wishlist_item.item.item_name,
        image_url: wishlist_item.item.image_url,
        price: wishlist_item.item.price,
        description: wishlist_item.item.description
      }
    end
  end
end
