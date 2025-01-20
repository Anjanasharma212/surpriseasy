class Group < ApplicationRecord
  belongs_to :user
  has_many :participants
  has_many :messages
  has_many :wishlists, through: :participants
  has_many :notifications, as: :notifiable
end
