require "rails_helper"

RSpec.describe DietChallenge, type: :model do
  describe "バリデーション" do
    context "入力内容が正常な場合" do
      it "有効である" do
        diet_challenge = build(:diet_challenge)

        expect(diet_challenge).to be_valid
      end
    end

    context "目標体重が開始体重と同じ場合" do
      it "無効である" do
        diet_challenge = build(:diet_challenge, start_weight: 60.0, target_weight: 60.0)

        expect(diet_challenge).to be_invalid
        expect(diet_challenge.errors[:target_weight]).to include("は開始体重より小さい値を入力してください")
      end
    end

    context "目標体重が開始体重より大きい場合" do
      it "無効である" do
        diet_challenge = build(:diet_challenge, start_weight: 60.0, target_weight: 65.0)

        expect(diet_challenge).to be_invalid
        expect(diet_challenge.errors[:target_weight]).to include("は開始体重より小さい値を入力してください")
      end
    end
  end
end

  context "開始体重が未入力の場合" do
  it "無効である" do
    diet_challenge = build(:diet_challenge, start_weight: nil)

    expect(diet_challenge).to be_invalid
    expect(diet_challenge.errors[:start_weight]).to be_present
  end
end


  context "目標体重が未入力の場合" do
  it "無効である" do
    diet_challenge = build(:diet_challenge, target_weight: nil)

    expect(diet_challenge).to be_invalid
    expect(diet_challenge.errors[:target_weight]).to be_present
  end
end

  context "開始日が未入力の場合" do
  it "無効である" do
    diet_challenge = build(:diet_challenge, started_at: nil)

    expect(diet_challenge).to be_invalid
    expect(diet_challenge.errors[:started_at]).to be_present
  end
end

  context "開始体重が0の場合" do
  it "無効である" do
    diet_challenge = build(:diet_challenge, start_weight: 0)

    expect(diet_challenge).to be_invalid
    expect(diet_challenge.errors[:start_weight]).to be_present
  end
end

  context "目標体重が0の場合" do
  it "無効である" do
    diet_challenge = build(:diet_challenge, target_weight: 0)

    expect(diet_challenge).to be_invalid
    expect(diet_challenge.errors[:target_weight]).to be_present
  end
end
