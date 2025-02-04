class AddParticipantIdToWishlist < ActiveRecord::Migration[8.0]
  def change
    remove_reference :wishlists, :user, foreign_key: true
    remove_reference :wishlists, :group, foreign_key: true
    add_reference :wishlists, :participant, foreign_key: true  
  end
end
