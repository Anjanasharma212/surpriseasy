class Group < ApplicationRecord
  belongs_to :user
  has_many :participants, dependent: :destroy
  has_many :users, through: :participants
  has_many :messages
  has_many :notifications, as: :notifiable

  accepts_nested_attributes_for :participants
  accepts_nested_attributes_for :user
end
