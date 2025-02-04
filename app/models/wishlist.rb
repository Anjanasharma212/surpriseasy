class Wishlist < ApplicationRecord
  belongs_to :participant  
  has_many :items, dependent: :destroy
end
