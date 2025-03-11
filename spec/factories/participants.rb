FactoryBot.define do
  factory :participant do
    user
    group
    is_admin { false }

    trait :as_admin do
      is_admin { true }
    end

    trait :with_drawn_name do
      after(:create) do |participant|
        drawn = create(:participant, group: participant.group)
        participant.update(drawn_name: drawn)
      end
    end
  end
end 
