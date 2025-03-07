require 'rails_helper'

RSpec.describe Assignment, type: :model do
  describe 'basic model behavior' do
    let(:group) { create(:group) }
    let(:participant1) { create(:participant, group: group) }
    let(:participant2) { create(:participant, group: group) }
    
    it 'can be created with valid attributes' do
      assignment = Assignment.new(
        group: group,
        giver: participant1,
        receiver: participant2
      )
      expect(assignment.save).to be true
    end

    it 'belongs to a group' do
      assignment = Assignment.new
      expect(assignment).to respond_to(:group)
    end

    it 'belongs to a giver' do
      assignment = Assignment.new
      expect(assignment).to respond_to(:giver)
    end

    it 'belongs to a receiver' do
      assignment = Assignment.new
      expect(assignment).to respond_to(:receiver)
    end

    it 'requires a group' do
      assignment = Assignment.new(
        giver: participant1,
        receiver: participant2
      )
      expect(assignment.save).to be false
      expect(assignment.errors[:group]).to include("must exist")
    end

  describe 'business logic' do
    let(:group) { create(:group) }
    let(:participant1) { create(:participant, group: group) }
    let(:participant2) { create(:participant, group: group) }

    it 'should validate that giver and receiver are different' do
      skip 'Validation not implemented yet'
      assignment = Assignment.new(
        group: group,
        giver: participant1,
        receiver: participant1
      )
      assignment.valid?
      expect(assignment.errors[:base]).to include("Giver and receiver can't be the same participant")
    end

    it 'should validate uniqueness within group' do
      skip 'Validation not implemented yet'
      # First assignment
      Assignment.create!(
        group: group,
        giver: participant1,
        receiver: participant2
      )

      duplicate = Assignment.new(
        group: group,
        giver: participant1,
        receiver: participant2
      )
      duplicate.valid?
      expect(duplicate.errors[:base]).to include("Participant can only have one assignment per group")
    end
  end
end 
