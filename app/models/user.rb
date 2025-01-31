class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  # has_secure_password

  has_many :participants
  has_many :groups, through: :participants # add association
  has_many :messages, foreign_key: 'sender_id'
  has_many :wishlists
  has_many :notifications 

  validates :password, presence: true, allow_nil: true
  # validates :email, presence: true, uniqueness: true

  def password_required?
    new_record? ? false : super
  end
end
