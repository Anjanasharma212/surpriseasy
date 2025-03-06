class Item < ApplicationRecord
  has_many :wishlist_items
  has_many :wishlists, through: :wishlist_items

  scope :by_category, ->(category) { where(category: category) if category.present? }
  scope :by_age, ->(age) { where(age: age) if age.present? }
  scope :by_gender, ->(gender) { where(gender: gender) if gender.present? }
  
  scope :by_price_range, ->(min_price, max_price) {
    return all unless min_price.present? || max_price.present?
    
    if min_price.present? && max_price.present?
      where("price BETWEEN ? AND ?", min_price, max_price)
    elsif min_price.present?
      where("price >= ?", min_price)
    else
      where("price <= ?", max_price)
    end
  }

  ransacker :price_search do
    Arel.sql('CAST(price AS TEXT)')
  end

  def self.ransackable_attributes(auth_object = nil)
    %w[item_name description category age gender price_search]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[wishlist_items wishlists]
  end

  def self.search_items(query)
    return all unless query.present?
    
    ransack({
      item_name_or_description_or_category_or_age_or_gender_or_price_search_cont_any: query
    }).result(distinct: true)
  end

  scope :by_search, ->(query) { search_items(query) if query.present? }

  def self.fetch_distinct_filters
    Rails.cache.fetch('item_filters', expires_in: 1.hour) do
      {
        categories: distinct.pluck(:category).compact,
        ages: distinct.pluck(:age).compact,
        genders: distinct.pluck(:gender).compact
      }
    end
  end

  after_commit :expire_filter_cache, on: [:create, :update, :destroy]

  private

  def expire_filter_cache
    Rails.cache.delete('item_filters')
  end
end
