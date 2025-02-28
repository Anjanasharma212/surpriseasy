class Item < ApplicationRecord
  has_many :wishlist_items
  has_many :wishlists, through: :wishlist_items

  scope :by_category, ->(category) { where(category: category) if category.present? }
  scope :by_age, ->(age) { where(age: age) if age.present? }
  scope :by_gender, ->(gender) { where(gender: gender) if gender.present? }
  
  scope :by_price_range, ->(min_price, max_price) {
    if min_price.present? && max_price.present?
      where("price >= ? AND price <= ?", min_price.to_i, max_price.to_i)
    elsif min_price.present?
      where("price >= ?", min_price.to_i)
    elsif max_price.present?
      where("price <= ?", max_price.to_i)
    end
  }

  scope :by_search, ->(query) {
    if query.present?
      search_term = "%#{query}%"
      where("item_name ILIKE ? OR price::TEXT ILIKE ?", search_term, search_term)
    end
  }

  def self.fetch_distinct_filters
    select('DISTINCT category, age, gender')
      .pluck(:category, :age, :gender)
      .transpose
      .then { |categories, ages, genders| 
        {
          categories: categories.compact,
          ages: ages.compact,
          genders: genders.compact
        }
      }
  end
end
