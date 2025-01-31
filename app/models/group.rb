class Group < ApplicationRecord
  belongs_to :user
  has_many :participants
  has_many :users, through: :participants  #add associations 
  has_many :messages
  has_many :wishlists, through: :participants
  has_many :notifications, as: :notifiable
  
  accepts_nested_attributes_for :participants
  accepts_nested_attributes_for :user
end
