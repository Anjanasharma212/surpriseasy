class Message < ApplicationRecord
  belongs_to :group
  belongs_to :sender, class_name: 'User', foreign_key: 'sender_id'
  has_many :notifications, as: :notifiable
end
