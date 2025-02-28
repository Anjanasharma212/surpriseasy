class GroupSerializer
  def initialize(group, current_user)
    @group = group
    @current_user = current_user
  end

  def format_group_details
    {
      id: @group.id,
      group_name: @group.group_name,
      event_date: @group.event_date,
      budget: @group.budget,
      logged_in_participant: format_logged_in_participant,
      participants: @group.participants.map { |p| format_participant(p) }
    }
  end

  private

  def format_logged_in_participant
    participant = @group.participants.find_by(user_id: @current_user.id)
    return nil unless participant

    {
      id: participant.id,
      drawn_name_id: participant.drawn_name_id,
      user: format_user(participant.user),
      wishlist_id: participant.wishlists.first&.id,
      wishlist_items_count: participant.wishlists.first&.wishlist_items&.count || 0,
      wishlist_items: format_wishlist_items(participant.wishlists.first)
    }
  end

  def format_participant(participant)
    {
      id: participant.id,
      email: participant.user.email,
      user: format_user(participant.user),
      wishlist_id: participant.wishlists.first&.id,
      wishlist_items_count: participant.wishlists.first&.wishlist_items&.count || 0,
      wishlist_items: format_wishlist_items(participant.wishlists.first)
    }
  end

  def format_user(user)
    {
      id: user.id,
      name: user.name,
      email: user.email
    }
  end

  def format_wishlist_items(wishlist)
    return [] unless wishlist&.wishlist_items&.any?

    wishlist.wishlist_items.map do |wishlist_item|
      {
        id: wishlist_item.id,
        item_name: wishlist_item.item.item_name,
        image_url: wishlist_item.item.image_url
      }
    end
  end
end 
