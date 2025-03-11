require 'rails_helper'

RSpec.describe Participant, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:group) }
    it { is_expected.to have_many(:wishlists).dependent(:destroy) }
    it { is_expected.to have_many(:assignments_as_giver)
          .class_name('Assignment')
          .with_foreign_key('giver_id')
          .dependent(:destroy) }
    it { is_expected.to have_many(:assignments_as_receiver)
          .class_name('Assignment')
          .with_foreign_key('receiver_id')
          .dependent(:destroy) }
    it { is_expected.to belong_to(:drawn_name)
          .class_name('Participant')
          .optional }
  end

  describe 'nested attributes' do
    it { is_expected.to accept_nested_attributes_for(:user) }
  end

  describe 'creation' do
    it 'is valid with valid attributes' do
      user = User.create!(
        name: 'Test User',
        email: 'test@example.com',
        password: 'password123'
      )
      group = Group.create!(
        group_name: 'Test Group',
        user: user,
        budget: 100
      )
      
      participant = Participant.new(
        user: user,
        group: group,
        is_admin: false
      )

      expect(participant).to be_valid
    end
  end

  describe 'drawn name functionality' do
    it 'can be assigned a drawn name' do
      user1 = User.create!(name: 'User 1', email: 'user1@example.com', password: 'password123')
      user2 = User.create!(name: 'User 2', email: 'user2@example.com', password: 'password123')
      
      group = Group.create!(group_name: 'Test Group', user: user1, budget: 100)
      participant1 = Participant.create!(user: user1, group: group, is_admin: true)
      participant2 = Participant.create!(user: user2, group: group, is_admin: false)

      participant1.drawn_name = participant2
      
      expect(participant1.save).to be true
      expect(participant1.drawn_name).to eq(participant2)
    end
  end

  describe 'assignments' do
    it 'can have multiple assignments as giver' do
      user = User.create!(name: 'Test User', email: 'test@example.com', password: 'password123')
      group = Group.create!(group_name: 'Test Group', user: user, budget: 100)
      participant = Participant.create!(user: user, group: group)
      
      assignment1 = Assignment.create!(giver_id: participant.id, receiver_id: 1, group: group)
      assignment2 = Assignment.create!(giver_id: participant.id, receiver_id: 2, group: group)
      
      expect(participant.assignments_as_giver).to include(assignment1, assignment2)
    end

    it 'can have multiple assignments as receiver' do
      user = User.create!(name: 'Test User', email: 'test@example.com', password: 'password123')
      group = Group.create!(group_name: 'Test Group', user: user, budget: 100)
      participant = Participant.create!(user: user, group: group)
      
      assignment1 = Assignment.create!(receiver_id: participant.id, giver_id: 1, group: group)
      assignment2 = Assignment.create!(receiver_id: participant.id, giver_id: 2, group: group)
      
      expect(participant.assignments_as_receiver).to include(assignment1, assignment2)
    end
  end
end 