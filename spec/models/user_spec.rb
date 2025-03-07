require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      user = User.new(
        name: 'John Doe',
        email: 'john@example.com',
        password: 'password123'
      )
      expect(user).to be_valid
    end

    it 'is not valid without a name' do
      user = User.new(name: nil)
      expect(user).not_to be_valid
    end
  end

  describe '#participant_groups' do
    it 'returns groups where user is a participant' do
      user = User.create!(name: 'Test User', email: 'test@example.com', password: 'password123')
      group = Group.create!(group_name: 'Test Group', user_id: user.id, budget: 100)
      Participant.create!(user: user, group: group)

      expect(user.participant_groups).to include(group)
    end
  end
end 
