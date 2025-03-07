require 'rails_helper'

RSpec.describe WishlistItem, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:wishlist) }
    it { is_expected.to belong_to(:item) }
  end

  describe 'wishlist item creation' do
    let(:user) { create(:user) }
    let(:group) { create(:group, user: user) }
    let(:participant) { create(:participant, user: user, group: group) }
    let(:wishlist) { create(:wishlist, participant: participant) }
    let(:item) { create(:item) }

    it 'creates a valid wishlist item' do
      wishlist_item = build(:wishlist_item, wishlist: wishlist, item: item)
      expect(wishlist_item).to be_valid
    end

    it 'is invalid without a wishlist' do
      wishlist_item = build(:wishlist_item, wishlist: nil, item: item)
      expect(wishlist_item).not_to be_valid
      expect(wishlist_item.errors[:wishlist]).to include("must exist")
    end

    it 'is invalid without an item' do
      wishlist_item = build(:wishlist_item, wishlist: wishlist, item: nil)
      expect(wishlist_item).not_to be_valid
      expect(wishlist_item.errors[:item]).to include("must exist")
    end

    it 'allows multiple items in a wishlist' do
      item1 = create(:item)
      item2 = create(:item)
      
      wishlist_item1 = create(:wishlist_item, wishlist: wishlist, item: item1)
      wishlist_item2 = create(:wishlist_item, wishlist: wishlist, item: item2)
      
      expect(wishlist.wishlist_items.count).to eq(2)
      expect(wishlist.items).to include(item1, item2)
    end
  end

  describe 'deletion behavior' do
    let(:user) { create(:user) }
    let(:group) { create(:group, user: user) }
    let(:participant) { create(:participant, user: user, group: group) }
    let(:wishlist) { create(:wishlist, participant: participant) }
    let(:item) { create(:item) }
    let!(:wishlist_item) { create(:wishlist_item, wishlist: wishlist, item: item) }

    it 'can be deleted' do
      expect {
        wishlist_item.destroy
      }.to change(WishlistItem, :count).by(-1)
    end

    it 'does not delete associated wishlist when deleted' do
      expect {
        wishlist_item.destroy
      }.not_to change(Wishlist, :count)
    end

    it 'does not delete associated item when deleted' do
      expect {
        wishlist_item.destroy
      }.not_to change(Item, :count)
    end
  end
end 
