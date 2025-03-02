class WishlistItem < ApplicationRecord
  belongs_to :wishlist
  belongs_to :item

  validates :item_id, presence: true
  validate :item_must_exist

  private

  def item_must_exist
    return if item.present?
    errors.add(:item_id, I18n.t('wishlists.errors.item_not_found'))
  end
end
