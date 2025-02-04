class Participant < ApplicationRecord
  belongs_to :user
  belongs_to :group
  has_many :wishlists, dependent: :destroy
  accepts_nested_attributes_for :user
end
