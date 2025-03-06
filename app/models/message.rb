class Message < ApplicationRecord
  belongs_to :group
  belongs_to :sender, class_name: 'User', foreign_key: 'sender_id'
  belongs_to :receiver, class_name: 'User', foreign_key: 'receiver_id', optional: true
  has_many :notifications, as: :notifiable

  validates :content, :sender, :group, presence: true

  scope :not_anonymous, -> { where(is_anonymous: false) }
  scope :anonymous, -> { where(is_anonymous: true) }
end
