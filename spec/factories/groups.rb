FactoryBot.define do
  factory :group do
    sequence(:group_name) { |n| "Test Group #{n}" }
    event_date { Date.tomorrow }
    budget { 1000 }
    message { "Welcome to the group!" }
    association :user

    trait :invalid do
      group_name { nil }
    end
  end
end 
