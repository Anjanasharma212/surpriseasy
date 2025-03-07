FactoryBot.define do
  factory :wishlist_item do
    association :wishlist
    association :item

    trait :with_specific_item do
      transient do
        item_name { "Specific Item" }
        price { 99.99 }
      end

      before(:create) do |wishlist_item, evaluator|
        wishlist_item.item = create(:item, 
          item_name: evaluator.item_name,
          price: evaluator.price
        )
      end
    end

    trait :with_participant do
      before(:create) do |wishlist_item|
        user = create(:user)
        group = create(:group, user: user)
        participant = create(:participant, user: user, group: group)
        wishlist_item.wishlist = create(:wishlist, participant: participant)
      end
    end
  end
end 
