class Message < ApplicationRecord

  # It should some schema or migration changes here for messaging 
  # add_index :messages, :sender_id
  # add_index :messages, :receiver_id


  belongs_to :group
  belongs_to :user, foreign_key: 'sender_id'
  belongs_to :receiver, class_name: 'User', optional: true
  # Add new for messages association , right way given below
  # belongs_to :sender, class_name: 'User', foreign_key: 'sender_id'
  # belongs_to :receiver, class_name: 'User', foreign_key: 'receiver_id',
  has_many :notifications, as: :notifiable
end
