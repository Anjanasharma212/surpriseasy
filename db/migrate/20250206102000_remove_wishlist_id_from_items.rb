class RemoveWishlistIdFromItems < ActiveRecord::Migration[8.0]
  def change
    remove_column :items, :wishlist_id, :integer
  end
end
