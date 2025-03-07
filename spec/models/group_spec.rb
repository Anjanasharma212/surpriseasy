require 'rails_helper'

RSpec.describe Group, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to have_many(:participants).dependent(:destroy) }
    it { is_expected.to have_many(:users).through(:participants) }
    it { is_expected.to have_many(:messages).dependent(:destroy) }
    it { is_expected.to have_many(:notifications).dependent(:destroy) }
    it { is_expected.to have_many(:assignments).dependent(:destroy) }
  end

  describe 'nested attributes' do
    it { is_expected.to accept_nested_attributes_for(:participants) }
    it { is_expected.to accept_nested_attributes_for(:user) }
  end

  describe 'validations' do
    it 'is valid with valid attributes' do
      user = User.create!(name: 'Test User', email: 'test@example.com', password: 'password123')
      group = Group.new(
        group_name: 'Test Group',
        user: user,
        budget: 100.00,
        event_name: 'Christmas Party',
        event_date: DateTime.now + 1.month
      )
      expect(group).to be_valid
    end
  end

  describe 'scopes' do
    describe '.for_user' do
      it 'returns groups where the user is a participant' do
        user = User.create!(name: 'Test User', email: 'test@example.com', password: 'password123')
        group1 = Group.create!(group_name: 'Group 1', user: user, budget: 100)
        group2 = Group.create!(group_name: 'Group 2', user: user, budget: 100)
        
        Participant.create!(user: user, group: group1)

        expect(Group.for_user(user)).to include(group1)
        expect(Group.for_user(user)).not_to include(group2)
      end
    end
  end

  describe 'messages ordering' do
    it 'orders messages by created_at in descending order' do
      user = User.create!(name: 'Test User', email: 'test@example.com', password: 'password123')
      group = Group.create!(group_name: 'Test Group', user: user, budget: 100)
      
      message1 = Message.create!(group: group, sender_id: user.id, content: 'First message')
      message2 = Message.create!(group: group, sender_id: user.id, content: 'Second message')
      
      expect(group.messages.first).to eq(message2)
      expect(group.messages.last).to eq(message1)
    end
  end
end 
