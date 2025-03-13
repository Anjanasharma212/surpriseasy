require 'rails_helper'

RSpec.describe ItemsController, type: :controller do
  login_user

  describe 'GET #index' do
    let!(:young_item) { create(:item, age: "12 years and under", price: 50) }
    let!(:teen_item) { create(:item, age: "12 - 18 years", price: 150) }
    let!(:adult_item) { create(:item, age: "25 - 35 years", price: 400) }

    let!(:electronics) { create(:item, :electronics, price: 500) }
    let!(:toy) { create(:item, :toys, price: 50) }
    let!(:clothes) { create(:item, :clothes, price: 100) }

    context 'without filters' do
      it 'returns all items' do
        get :index, format: :json
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body).length).to eq(6)
      end
    end

    context 'with category filter' do
      it 'returns items in specified category' do
        get :index, params: { category: 'Electronics' }, format: :json
        
        items = JSON.parse(response.body)
        expect(items.length).to eq(1)
        expect(items.first['category']).to eq('Electronics')
      end
    end

    context 'with age filter' do
      it 'returns items for specified age group' do
        get :index, params: { age: "12 years and under" }, format: :json
        
        items = JSON.parse(response.body)
        expect(items.length).to eq(1)
        expect(items.first['age']).to eq("12 years and under")
      end
    end

    context 'with gender filter' do
      it 'returns items for specified gender' do
        get :index, params: { gender: 'Unisex' }, format: :json
        
        items = JSON.parse(response.body)
        expect(items.all? { |item| item['gender'] == 'Unisex' }).to be true
      end
    end

    context 'with price range filter' do
      it 'returns items within price range' do
        get :index, params: { minPrice: 100, maxPrice: 200 }, format: :json
        
        items = JSON.parse(response.body)
        expect(items.length).to eq(2)
        expect(items.all? { |item| item['price'].to_f.between?(100, 200) }).to be true
      end

      it 'returns items above minimum price' do
        get :index, params: { minPrice: 300 }, format: :json
        
        items = JSON.parse(response.body)
        expect(items.length).to eq(2)
        expect(items.all? { |item| item['price'].to_f >= 300 }).to be true
      end

      it 'returns items below maximum price' do
        get :index, params: { maxPrice: 100 }, format: :json
        items = JSON.parse(response.body)
        expect(items.length).to eq(3)
        expect(items.all? { |item| item['price'].to_f <= 100 }).to be true
      end
    end

    context 'with search query' do
      let!(:searchable_item) { create(:item, item_name: 'Special Gaming Console') }

      it 'returns items matching search query' do
        get :index, params: { search: 'Gaming' }, format: :json
        
        items = JSON.parse(response.body)
        expect(items.length).to eq(1)
        expect(items.first['item_name']).to include('Gaming')
      end
    end

    context 'with multiple filters' do
      it 'returns items matching all criteria' do
        get :index, params: {
          category: 'Electronics',
          age: '18+',
          maxPrice: 600
        }, format: :json
        
        items = JSON.parse(response.body)
        expect(items.length).to eq(1)
        expect(items.first['category']).to eq('Electronics')
        expect(items.first['age']).to eq('18+')
        expect(items.first['price'].to_f).to be <= 600
      end
    end
  end

  describe 'GET #filters' do
    before do
      create(:item, gender: 'Female')
      create(:item, gender: 'Male')
      create(:item, gender: 'Unisex')
    end

    it 'returns distinct filter options' do
      get :filters, format: :json
      
      filters = JSON.parse(response.body)
      expect(response).to have_http_status(:ok)
      expect(filters['genders']).to include('Female', 'Male', 'Unisex')
    end

    it 'returns cached results' do
      expect(Rails.cache).to receive(:fetch).with('item_filters', expires_in: 1.hour)
      
      get :filters, format: :json
    end
  end
end 
