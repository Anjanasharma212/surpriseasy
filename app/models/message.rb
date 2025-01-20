class Message < ApplicationRecord
  belongs_to :group
  belongs_to :user, foreign_key: 'sender_id'
  belongs_to :receiver, class_name: 'User', optional: true
  has_many :notifications, as: :notifiable
end
