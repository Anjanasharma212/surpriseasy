class WishlistSerializer
  def initialize(wishlist)
    @wishlist = wishlist
  end

  def as_json(*)
    {
      id: @wishlist.id,
      participant_id: @wishlist.participant_id,
      items: @wishlist.wishlist_items.includes(:item).map do |wishlist_item|
        {
          id: wishlist_item.item.id,
          item_name: wishlist_item.item.item_name,
          description: wishlist_item.item.description,
          image_url: wishlist_item.item.image_url,
          price: wishlist_item.item.price,
          wishlist_item_id: wishlist_item.id 
        }
      end
    }
  end
end
