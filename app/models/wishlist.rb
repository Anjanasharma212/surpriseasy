class Wishlist < ApplicationRecord
  belongs_to :participant
  has_many :wishlist_items, dependent: :destroy
  has_many :items, through: :wishlist_items
  accepts_nested_attributes_for :wishlist_items, allow_destroy: true

  # validates :participant_id, presence: true
end
