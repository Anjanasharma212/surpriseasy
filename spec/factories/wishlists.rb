FactoryBot.define do
  factory :wishlist do
    association :participant

    trait :with_items do
      after(:create) do |wishlist|
        create_list(:wishlist_item, 2, wishlist: wishlist)
      end
    end
  end
end 
