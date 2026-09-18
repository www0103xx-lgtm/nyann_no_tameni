FactoryBot.define do
  factory :cat do
    association :diet_challenge
    name { "ミケ" }
    energy_points { 0 }
  end
end
