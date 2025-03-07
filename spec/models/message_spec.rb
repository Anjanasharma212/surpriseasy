require 'rails_helper'

RSpec.describe Message, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:group) }
    it { is_expected.to belong_to(:sender).class_name('User') }
    it { is_expected.to belong_to(:receiver).class_name('User').optional }
    it { is_expected.to have_many(:notifications) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:content) }
    it { is_expected.to validate_presence_of(:sender) }
    it { is_expected.to validate_presence_of(:group) }
  end

  describe 'scopes' do
    let(:user1) { create(:user) }
    let(:user2) { create(:user) }
    let(:group) { create(:group, user: user1) }

    let!(:anonymous_message) do
      create(:message, 
        group: group, 
        sender: user1, 
        receiver: user2, 
        is_anonymous: true
      )
    end

    let!(:normal_message) do
      create(:message, 
        group: group, 
        sender: user1, 
        receiver: user2, 
        is_anonymous: false
      )
    end

    describe '.not_anonymous' do
      it 'returns only non-anonymous messages' do
        expect(Message.not_anonymous).to include(normal_message)
        expect(Message.not_anonymous).not_to include(anonymous_message)
      end
    end

    describe '.anonymous' do
      it 'returns only anonymous messages' do
        expect(Message.anonymous).to include(anonymous_message)
        expect(Message.anonymous).not_to include(normal_message)
      end
    end
  end

  describe 'message creation' do
    let(:user1) { create(:user) }
    let(:user2) { create(:user) }
    let(:group) { create(:group, user: user1) }

    it 'creates a valid message' do
      message = build(:message,
        content: 'Hello!',
        group: group,
        sender: user1,
        receiver: user2,
        is_anonymous: false
      )
      expect(message).to be_valid
    end

    it 'creates a valid anonymous message' do
      message = build(:message,
        content: 'Secret message',
        group: group,
        sender: user1,
        receiver: user2,
        is_anonymous: true
      )
      expect(message).to be_valid
    end

    it 'is valid without a receiver' do
      message = build(:message,
        content: 'Group message',
        group: group,
        sender: user1,
        receiver: nil,
        is_anonymous: false
      )
      expect(message).to be_valid
    end

    it 'is invalid without content' do
      message = build(:message, :without_content)
      expect(message).not_to be_valid
      expect(message.errors[:content]).to include("can't be blank")
    end

    it 'is invalid without a sender' do
      message = build(:message, :without_sender)
      expect(message).not_to be_valid
      expect(message.errors[:sender]).to include("can't be blank")
    end

    it 'is invalid without a group' do
      message = build(:message, :without_group)
      expect(message).not_to be_valid
      expect(message.errors[:group]).to include("can't be blank")
    end
  end
end 
