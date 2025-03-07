class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :invitable

  has_many :participants
  has_many :groups, through: :participants 

  has_many :sent_messages, class_name: 'Message', foreign_key: 'sender_id', dependent: :destroy
  has_many :notifications 

  validates :password, presence: true, allow_nil: true
  # validates :email, presence: true, uniqueness: true

  def password_required?
    new_record? ? false : super
  end

  def participant_groups
    Group.where(id: Participant.where(user_id: id).pluck(:group_id))
  end
end
