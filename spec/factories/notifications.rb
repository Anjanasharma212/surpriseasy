FactoryBot.define do
  factory :notification do
    association :recipient, factory: :user
    title { "Test Notification" }
    body { "This is a test notification" }
    read_at { nil }

    trait :read do
      read_at { Time.current }
    end

    trait :with_message do
      association :notifiable, factory: :message
    end

    trait :with_group do
      association :notifiable, factory: :group
    end

    trait :system_notification do
      notifiable { nil }
      title { "System Notification" }
      body { "System wide notification" }
    end
  end
end
