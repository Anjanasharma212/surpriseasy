class ParticipantSerializer
  def initialize(participant)
    @participant = participant
  end

  def format_participant_details
    return nil unless @participant

    {
      participant_id: @participant.id,
      group_id: @participant.group_id,
      drawn_name: format_drawn_name(@participant.drawn_name),
      user: format_user(@participant.user),
      wishlists: format_wishlists(@participant.wishlists)
    }
  end

  private

  def format_drawn_name(drawn_participant)
    return nil unless drawn_participant

    {
      id: drawn_participant.user.id,
      name: drawn_participant.user.name,
      email: drawn_participant.user.email,
      wishlists: format_wishlists(drawn_participant.wishlists)
    }
  end

  def format_user(user)
    return {} unless user

    {
      id: user.id,
      name: user.name,
      email: user.email
    }
  end

  def format_wishlists(wishlists)
    wishlists.map do |wishlist|
      format_wishlist(wishlist)
    end
  end

  def format_wishlist(wishlist)
    return {} unless wishlist

    {
      id: wishlist.id,
      wishlist_items: format_wishlist_items(wishlist.wishlist_items),
      wishlist_items_count: wishlist.wishlist_items.count
    }
  end

  def format_wishlist_items(items)
    return [] unless items

    items.map { |item| format_wishlist_item(item) }
  end

  def format_wishlist_item(wishlist_item)
    return {} unless wishlist_item && wishlist_item.item

    {
      id: wishlist_item.id,
      item_name: wishlist_item.item.item_name,
      image_url: wishlist_item.item.image_url
    }
  end
end 
