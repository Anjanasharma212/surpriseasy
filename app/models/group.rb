class Group < ApplicationRecord
  belongs_to :user
  has_many :participants, dependent: :destroy
  has_many :users, through: :participants
  has_many :messages, dependent: :destroy
  has_many :notifications, as: :notifiable, dependent: :destroy
  has_many :assignments, dependent: :destroy

  accepts_nested_attributes_for :participants
  accepts_nested_attributes_for :user
end
