FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    sequence(:name) { |n| "Test User #{n}" }
    password { "password123" }
    password_confirmation { "password123" }


    trait :invitation_accepted do
      after(:create) do |user|
        user.update!(
          invitation_token: nil,
          invitation_accepted_at: Time.current,
          invitation_created_at: Time.current
        )
      end
    end
  end
end 
