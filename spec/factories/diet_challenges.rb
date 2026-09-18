FactoryBot.define do
  factory :diet_challenge do
    association :user
    start_weight { 60.0 }
    target_weight { 55.0 }
    started_at { Date.current }
    achieved_at { nil }
  end
end
