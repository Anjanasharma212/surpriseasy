require 'rails_helper'

RSpec.describe Wishlist, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:participant) }
    it { is_expected.to have_many(:wishlist_items).dependent(:destroy) }
    it { is_expected.to have_many(:items).through(:wishlist_items) }
  end

  describe 'nested attributes' do
    it { is_expected.to accept_nested_attributes_for(:wishlist_items).allow_destroy(true) }
  end

  describe 'creation and manipulation' do
    let!(:user) { create(:user) }
    let!(:group) { create(:group, user: user) }
    let!(:participant) { create(:participant, user: user, group: group) }
    let!(:item) { create(:item) }

    it 'creates a valid wishlist' do
      wishlist = build(:wishlist, participant: participant)
      expect(wishlist).to be_valid
    end

    it 'can add items through wishlist_items' do
      wishlist = create(:wishlist, participant: participant)
      wishlist_item = create(:wishlist_item, wishlist: wishlist, item: item)

      expect(wishlist.items).to include(item)
    end

    it 'can add multiple items' do
      wishlist = create(:wishlist, participant: participant)
      item1 = create(:item)
      item2 = create(:item)

      create(:wishlist_item, wishlist: wishlist, item: item1)
      create(:wishlist_item, wishlist: wishlist, item: item2)

      expect(wishlist.items.count).to eq(2)
      expect(wishlist.items).to include(item1, item2)
    end

    it 'destroys associated wishlist_items when destroyed' do
      wishlist = create(:wishlist, participant: participant)
      wishlist_item = create(:wishlist_item, wishlist: wishlist, item: item)

      expect { wishlist.destroy }.to change(WishlistItem, :count).by(-1)
    end
  end

  describe 'nested attributes behavior' do
    let!(:user) { create(:user) }
    let!(:group) { create(:group, user: user) }
    let!(:participant) { create(:participant, user: user, group: group) }
    let!(:item) { create(:item) }

    it 'creates wishlist items through nested attributes' do
      wishlist = build(:wishlist, 
        participant: participant,
        wishlist_items_attributes: [
          { item_id: item.id }
        ]
      )

      expect { wishlist.save }.to change(WishlistItem, :count).by(1)
    end

    it 'removes wishlist items through nested attributes' do
      wishlist = create(:wishlist, participant: participant)
      wishlist_item = create(:wishlist_item, wishlist: wishlist, item: item)

      expect {
        wishlist.update(
          wishlist_items_attributes: [
            { id: wishlist_item.id, _destroy: '1' }
          ]
        )
      }.to change(WishlistItem, :count).by(-1)
    end
  end
end 
