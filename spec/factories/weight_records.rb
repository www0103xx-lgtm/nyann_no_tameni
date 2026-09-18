FactoryBot.define do
  factory :weight_record do
    association :diet_challenge
    weight { 60.0 }
    recorded_on { Date.current }
  end
end
