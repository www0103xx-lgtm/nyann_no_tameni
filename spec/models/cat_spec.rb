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

  describe "#growth_stage" do
    context "目標体重を達成していない場合" do
      it "0ポイントの場合はガリガリにゃんこと判定される" do
        cat = build(:cat, energy_points: 0)

        expect(cat.growth_stage).to eq("ガリガリにゃんこ")
      end

      it "20ポイントの場合はガリガリにゃんこと判定される" do
        cat = build(:cat, energy_points: 20)

        expect(cat.growth_stage).to eq("ガリガリにゃんこ")
      end

      it "21ポイントの場合は痩せ気味にゃんこと判定される" do
        cat = build(:cat, energy_points: 21)

        expect(cat.growth_stage).to eq("痩せ気味にゃんこ")
      end

      it "50ポイントの場合は痩せ気味にゃんこと判定される" do
        cat = build(:cat, energy_points: 50)

        expect(cat.growth_stage).to eq("痩せ気味にゃんこ")
      end

      it "51ポイントの場合は普通にゃんこと判定される" do
        cat = build(:cat, energy_points: 51)

        expect(cat.growth_stage).to eq("普通にゃんこ")
      end

      it "51ポイント以上でも目標体重を達成していなければ普通にゃんこと判定される" do
        diet_challenge = create(
          :diet_challenge,
          start_weight: 60.0,
          target_weight: 55.0
        )
        cat = create(
          :cat,
          diet_challenge: diet_challenge,
          energy_points: 60
        )
        create(
          :weight_record,
          diet_challenge: diet_challenge,
          weight: 55.1,
          recorded_on: Date.current
        )

        expect(cat.growth_stage).to eq("普通にゃんこ")
      end
    end

    context "目標体重を達成している場合" do
      it "目標体重と同じ体重ならまん丸にゃんこと判定される" do
        diet_challenge = create(
          :diet_challenge,
          start_weight: 60.0,
          target_weight: 55.0
        )
        cat = create(
          :cat,
          diet_challenge: diet_challenge,
          energy_points: 10
        )
        create(
          :weight_record,
          diet_challenge: diet_challenge,
          weight: 55.0,
          recorded_on: Date.current
        )

        expect(cat.growth_stage).to eq("まん丸にゃんこ")
      end

      it "目標体重より軽ければまん丸にゃんこと判定される" do
        diet_challenge = create(
          :diet_challenge,
          start_weight: 60.0,
          target_weight: 55.0
        )
        cat = create(
          :cat,
          diet_challenge: diet_challenge,
          energy_points: 10
        )
        create(
          :weight_record,
          diet_challenge: diet_challenge,
          weight: 54.9,
          recorded_on: Date.current
        )

        expect(cat.growth_stage).to eq("まん丸にゃんこ")
      end
    end
  end
end
