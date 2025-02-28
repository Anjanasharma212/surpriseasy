class ParticipantSerializer
  def initialize(participant)
    @participant = participant
  end

  def format_participant_details
    return nil unless @participant

    {
      id: @participant.id,
      drawn_name_id: @participant.drawn_name_id,
      user: format_user(@participant.user),
      wishlist: format_wishlist(@participant.wishlists.first)
    }
  end

  private

  def format_user(user)
    {
      id: user.id,
      name: user.name,
      email: user.email
    }
  end

  def format_wishlist(wishlist)
    return nil unless wishlist

    {
      id: wishlist.id,
      wishlist_items: wishlist.wishlist_items.map { |item| format_wishlist_item(item) }
    }
  end

  def format_wishlist_item(wishlist_item)
    {
      id: wishlist_item.id,
      item_name: wishlist_item.item.item_name,
      image_url: wishlist_item.item.image_url
    }
  end
end 
