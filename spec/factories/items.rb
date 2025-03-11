FactoryBot.define do
  factory :item do
    sequence(:item_name) { |n| "Item #{n}" }
    price { 100.0 }
    description { "A test item" }
    image_url { "http://example.com/image.jpg" }
    age { ['0-12', '13-18', '18+'].sample }
    gender { ['Male', 'Female', 'Unisex'].sample }
    category { Faker::Commerce.department }

    trait :electronics do
      category { 'Electronics' }
      age { '18+' }
    end

    trait :toys do
      category { 'Toys' }
      age { '0-12' }
    end

    trait :clothes do
      category { 'Clothes' }
      gender { ['Male', 'Female'].sample }
    end
  end
end 
