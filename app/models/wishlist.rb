class Wishlist < ApplicationRecord
  belongs_to :user
  belongs_to :group
  has_many :items
end
