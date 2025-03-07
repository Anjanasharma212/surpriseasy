require 'rails_helper'

RSpec.describe Item, type: :model do
  describe 'associations' do
    it { is_expected.to have_many(:wishlist_items) }
    it { is_expected.to have_many(:wishlists).through(:wishlist_items) }
  end

  describe 'scopes' do
    let!(:item1) { create(:item, category: 'Electronics', age: '18+', gender: 'Unisex', price: 100) }
    let!(:item2) { create(:item, category: 'Toys', age: '0-12', gender: 'Male', price: 50) }
    let!(:item3) { create(:item, category: 'Clothes', age: '13-18', gender: 'Female', price: 75) }

    describe '.by_category' do
      it 'filters items by category' do
        expect(Item.by_category('Electronics')).to include(item1)
        expect(Item.by_category('Electronics')).not_to include(item2, item3)
      end

      it 'returns all items when category is blank' do
        expect(Item.by_category(nil)).to include(item1, item2, item3)
      end
    end

    describe '.by_age' do
      it 'filters items by age' do
        expect(Item.by_age('18+')).to include(item1)
        expect(Item.by_age('18+')).not_to include(item2, item3)
      end

      it 'returns all items when age is blank' do
        expect(Item.by_age(nil)).to include(item1, item2, item3)
      end
    end

    describe '.by_gender' do
      it 'filters items by gender' do
        expect(Item.by_gender('Female')).to include(item3)
        expect(Item.by_gender('Female')).not_to include(item1, item2)
      end

      it 'returns all items when gender is blank' do
        expect(Item.by_gender(nil)).to include(item1, item2, item3)
      end
    end

    describe '.by_price_range' do
      it 'filters items between min and max price' do
        expect(Item.by_price_range(60, 80)).to include(item3)
        expect(Item.by_price_range(60, 80)).not_to include(item1, item2)
      end

      it 'filters items above min price' do
        expect(Item.by_price_range(80, nil)).to include(item1)
        expect(Item.by_price_range(80, nil)).not_to include(item2, item3)
      end

      it 'filters items below max price' do
        expect(Item.by_price_range(nil, 60)).to include(item2)
        expect(Item.by_price_range(nil, 60)).not_to include(item1, item3)
      end

      it 'returns all items when no price range is specified' do
        expect(Item.by_price_range(nil, nil)).to include(item1, item2, item3)
      end
    end
  end

  describe '.search_items' do
    let!(:item1) { create(:item, item_name: 'PlayStation 5', description: 'Gaming console') }
    let!(:item2) { create(:item, item_name: 'Xbox', description: 'Another gaming console') }
    let!(:item3) { create(:item, item_name: 'Teddy Bear', description: 'Soft toy') }

    it 'searches items by name' do
      results = Item.search_items('PlayStation')
      expect(results).to include(item1)
      expect(results).not_to include(item2, item3)
    end

    it 'searches items by description' do
      results = Item.search_items('gaming')
      expect(results).to include(item1, item2)
      expect(results).not_to include(item3)
    end

    it 'returns all items when query is blank' do
      results = Item.search_items(nil)
      expect(results).to include(item1, item2, item3)
    end
  end

  describe '.fetch_distinct_filters' do
    before do
      Rails.cache.clear
      create(:item, category: 'Electronics', age: '18+', gender: 'Unisex')
      create(:item, category: 'Toys', age: '0-12', gender: 'Male')
    end

    it 'returns distinct filter values' do
      filters = Item.fetch_distinct_filters

      expect(filters[:categories]).to contain_exactly('Electronics', 'Toys')
      expect(filters[:ages]).to contain_exactly('18+', '0-12')
      expect(filters[:genders]).to contain_exactly('Unisex', 'Male')
    end

    it 'caches the results' do
      expect(Rails.cache).to receive(:fetch).with('item_filters', expires_in: 1.hour)
      Item.fetch_distinct_filters
    end
  end

  describe 'cache expiration' do
    let(:item) { create(:item) }

    before do
      Rails.cache.clear
    end

    it 'invalidates cache on create' do
      Rails.cache.write('item_filters', { categories: [] })
      create(:item, category: 'New Category')
      expect(Rails.cache.read('item_filters')).to be_nil
    end

    it 'invalidates cache on update' do
      Rails.cache.write('item_filters', { categories: [] })
      item.update(category: 'New Category')
      expect(Rails.cache.read('item_filters')).to be_nil
    end

    it 'invalidates cache on destroy' do
      Rails.cache.write('item_filters', { categories: [] })
      item.destroy
      expect(Rails.cache.read('item_filters')).to be_nil
    end
  end

  describe 'ransackable attributes and associations' do
    it 'returns allowed ransackable attributes' do
      expected_attributes = %w[item_name description category age gender price_search]
      expect(Item.ransackable_attributes).to match_array(expected_attributes)
    end

    it 'returns allowed ransackable associations' do
      expected_associations = %w[wishlist_items wishlists]
      expect(Item.ransackable_associations).to match_array(expected_associations)
    end
  end
end 
