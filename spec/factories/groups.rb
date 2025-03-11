FactoryBot.define do
  factory :group do
    sequence(:group_name) { |n| "Test Group #{n}" }
    event_date { Date.tomorrow }
    budget { 1000 }
    message { "Welcome!" }
    user

    trait :with_participants do
      after(:create) do |group|
        create(:participant, group: group, user: group.user)
      end
    end

    trait :empty do
      after(:create) do |group|
        group.participants.destroy_all
      end
    end

    trait :invalid do
      group_name { nil }
    end
  end
end 
