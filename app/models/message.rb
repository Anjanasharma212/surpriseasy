class Message < ApplicationRecord
  belongs_to :group
  belongs_to :sender, class_name: 'User', foreign_key: 'sender_id'
  belongs_to :receiver, class_name: 'User', foreign_key: 'receiver_id', optional: true
  has_many :notifications, as: :notifiable

  validates :message, presence: true
  before_validation :set_is_anonymous

  private

  def set_is_anonymous
    if self.receiver_id.present? && is_anonymous.nil?
      self.is_anonymous = true  
    end
  end
end
