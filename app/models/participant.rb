class Participant < ApplicationRecord
  belongs_to :user
  belongs_to :group
  has_many :wishlists, dependent: :destroy
  has_many :assignments_as_giver, class_name: 'Assignment', foreign_key: 'giver_id', dependent: :destroy
  has_many :assignments_as_receiver, class_name: 'Assignment', foreign_key: 'receiver_id', dependent: :destroy
  belongs_to :drawn_name, class_name: 'Participant', optional: true

  accepts_nested_attributes_for :user
end
