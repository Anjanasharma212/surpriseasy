FactoryBot.define do
  factory :assignment do
    association :group
    association :giver, factory: :participant
    association :receiver, factory: :participant

    trait :with_different_users do
      after(:build) do |assignment|
        user1 = create(:user)
        user2 = create(:user)
        group = assignment.group || create(:group, user: user1)
        
        assignment.giver = create(:participant, user: user1, group: group)
        assignment.receiver = create(:participant, user: user2, group: group)
      end
    end

    trait :with_same_group do
      transient do
        user { create(:user) }
      end

      after(:build) do |assignment, evaluator|
        group = create(:group, user: evaluator.user)
        assignment.group = group
        assignment.giver = create(:participant, user: evaluator.user, group: group)
        assignment.receiver = create(:participant, user: create(:user), group: group)
      end
    end
  end
end 
