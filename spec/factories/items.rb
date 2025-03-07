FactoryBot.define do
  factory :item do
    item_name { Faker::Commerce.product_name }
    price { Faker::Commerce.price(range: 10.0..1000.0) }
    description { Faker::Lorem.paragraph }
    image_url { Faker::Internet.url }
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
