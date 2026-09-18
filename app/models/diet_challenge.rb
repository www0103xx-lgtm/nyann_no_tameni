class DietChallenge < ApplicationRecord
  belongs_to :user
  has_one :cat
  has_many :weight_records

  accepts_nested_attributes_for :cat

  validates :start_weight, presence: true, numericality: { greater_than: 0 }
  validates :target_weight, presence: true, numericality: { greater_than: 0 }
  validates :started_at, presence: true
  validate :target_weight_less_than_start_weight

  private

  def target_weight_less_than_start_weight
    return if start_weight.blank? || target_weight.blank?
    return if target_weight < start_weight

    errors.add(:target_weight, "は開始体重より小さい値を入力してください")
  end
end
