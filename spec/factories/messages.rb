FactoryBot.define do
  factory :message do
    content { Faker::Lorem.sentence }
    is_anonymous { false }
    read { false }
    association :group
    association :sender, factory: :user
    association :receiver, factory: :user

    trait :anonymous do
      is_anonymous { true }
    end

    trait :read do
      read { true }
    end

    trait :without_receiver do
      receiver { nil }
    end

    # For creating messages without specific attributes
    trait :without_content do
      content { nil }
    end

    trait :without_sender do
      sender { nil }
    end

    trait :without_group do
      group { nil }
    end
  end
end 
