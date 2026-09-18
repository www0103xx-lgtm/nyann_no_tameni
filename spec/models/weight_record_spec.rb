require "rails_helper"

RSpec.describe WeightRecord, type: :model do
  describe "バリデーション" do
    it "体重と記録日があれば有効である" do
      weight_record = build(:weight_record)

      expect(weight_record).to be_valid
    end

    it "体重がない場合は無効である" do
      weight_record = build(:weight_record, weight: nil)

      expect(weight_record).to be_invalid
    end

    it "体重が0の場合は無効である" do
      weight_record = build(:weight_record, weight: 0)

      expect(weight_record).to be_invalid
    end

    it "体重が負の値の場合は無効である" do
      weight_record = build(:weight_record, weight: -1)

      expect(weight_record).to be_invalid
    end

    it "記録日がない場合は無効である" do
      weight_record = build(:weight_record, recorded_on: nil)

      expect(weight_record).to be_invalid
    end

    it "同じダイエット挑戦で同じ日に2件の体重記録は作成できない" do
      diet_challenge = create(:diet_challenge)
      create(:weight_record, diet_challenge: diet_challenge, recorded_on: Date.current)

      weight_record = build(
        :weight_record,
        diet_challenge: diet_challenge,
        recorded_on: Date.current
      )

      expect(weight_record).to be_invalid
    end

    it "同じダイエット挑戦でも記録日が異なれば作成できる" do
      diet_challenge = create(:diet_challenge)
      create(:weight_record, diet_challenge: diet_challenge, recorded_on: Date.current)

      weight_record = build(
        :weight_record,
        diet_challenge: diet_challenge,
        recorded_on: Date.current + 1.day
      )

      expect(weight_record).to be_valid
    end

    it "異なるダイエット挑戦なら同じ日でも作成できる" do
      create(:weight_record, recorded_on: Date.current)

      weight_record = build(:weight_record, recorded_on: Date.current)

      expect(weight_record).to be_valid
    end
  end
end
