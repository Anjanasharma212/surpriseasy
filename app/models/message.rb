class Message < ApplicationRecord
  belongs_to :group
  belongs_to :sender, class_name: 'User', foreign_key: 'sender_id'
  belongs_to :receiver, class_name: 'User', foreign_key: 'receiver_id', optional: true
  has_many :notifications, as: :notifiable

  validates :content, presence: true
  validates :sender, presence: true
  validates :group, presence: true

  scope :not_anonymous, -> { where(is_anonymous: false) }
  scope :anonymous, -> { where(is_anonymous: true) }
  scope :by_date_asc, -> { order(created_at: :asc) }

  before_validation :set_is_anonymous

  private

  def set_is_anonymous
    self.is_anonymous = receiver_id.present? if is_anonymous.nil?
  end
end
