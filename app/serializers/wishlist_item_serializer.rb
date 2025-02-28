class WishlistItemSerializer
  def initialize(wishlist_item)
    @wishlist_item = wishlist_item
  end

  def format_item_details
    {
      id: @wishlist_item.id,
      item_name: @wishlist_item.item.item_name,
      image_url: @wishlist_item.item.image_url
    }
  end
end 
