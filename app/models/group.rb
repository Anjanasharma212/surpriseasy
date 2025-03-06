class Group < ApplicationRecord
  belongs_to :user
  has_many :participants, dependent: :destroy
  has_many :users, through: :participants
  has_many :messages, -> { order(created_at: :desc) }, dependent: :destroy
  has_many :notifications, as: :notifiable, dependent: :destroy
  has_many :assignments, dependent: :destroy

  accepts_nested_attributes_for :participants
  accepts_nested_attributes_for :user

  scope :for_user, ->(user) { joins(:participants).where(participants: { user_id: user.id }) }
end
