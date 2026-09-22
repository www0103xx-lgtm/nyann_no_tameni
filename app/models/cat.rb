class Cat < ApplicationRecord
  belongs_to :diet_challenge

  validates :name, presence: true
  validates :energy_points, numericality: { greater_than_or_equal_to: 0 }

  def growth_stage
    return "まん丸にゃんこ" if target_weight_achieved?

    case energy_points
    when 0..20
      "ガリガリにゃんこ"
    when 21..50
      "痩せ気味にゃんこ"
    else
      "普通にゃんこ"
    end
  end

  def image_path
    case growth_stage
    when "ガリガリにゃんこ"
      "cats/skinny.png"
    when "痩せ気味にゃんこ"
      "cats/slim.png"
    when "普通にゃんこ"
      "cats/normal.png"
    when "まん丸にゃんこ"
      "cats/round.png"
    end
  end

  def message
    case growth_stage
    when "ガリガリにゃんこ"
      "お腹すいたにゃ……"
    when "痩せ気味にゃんこ"
      "少し元気になってきたにゃ！"
    when "普通にゃんこ"
      "元気いっぱいにゃ！"
    when "まん丸にゃんこ"
      "目標達成！しあわせにゃ！"
    end
  end

  private

  def target_weight_achieved?
    latest_weight_record = diet_challenge.weight_records.order(recorded_on: :desc, id: :desc).first

    return false unless latest_weight_record

    latest_weight_record.weight <= diet_challenge.target_weight
  end
end
