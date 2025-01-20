class User < ApplicationRecord
  # has_secure_password

  has_many :participants
  has_many :messages, foreign_key: 'sender_id'
  has_many :wishlists
  has_many :notifications
end
