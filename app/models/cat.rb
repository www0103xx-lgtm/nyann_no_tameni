class Cat < ApplicationRecord
  belongs_to :diet_challenge

  validates :name, presence: true
  validates :energy_points, numericality: { greater_than_or_equal_to: 0 }
end
