require "rails_helper"

RSpec.describe Cat, type: :model do
  describe "バリデーション" do
    context "入力内容が正常な場合" do
      it "有効である" do
        cat = build(:cat)

        expect(cat).to be_valid
      end
    end

    context "名前が未入力の場合" do
      it "無効である" do
        cat = build(:cat, name: nil)

        expect(cat).to be_invalid
        expect(cat.errors[:name]).to be_present
      end
    end

    context "元気ポイントがマイナスの場合" do
      it "無効である" do
        cat = build(:cat, energy_points: -1)

        expect(cat).to be_invalid
        expect(cat.errors[:energy_points]).to be_present
      end
    end
  end
end
