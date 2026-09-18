class WeightRecord < ApplicationRecord
  belongs_to :diet_challenge

  validates :weight, presence: true, numericality: { greater_than: 0 }
  validates :recorded_on, presence: true,
                          uniqueness: { scope: :diet_challenge_id }
end
