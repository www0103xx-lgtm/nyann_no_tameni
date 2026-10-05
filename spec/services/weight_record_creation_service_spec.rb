require "rails_helper"

RSpec.describe WeightRecordCreationService do
  let(:user) { create(:user) }
  let(:diet_challenge) { create(:diet_challenge, user: user) }
  let!(:cat) { create(:cat, diet_challenge: diet_challenge) }

  describe "#call" do
    it "体重記録を保存し、猫の元気ポイントを1増やす" do
      weight_record = diet_challenge.weight_records.build(
        weight: 60.0,
        recorded_on: Date.current
      )

      expect {
        described_class.new(weight_record).call
      }.to change(WeightRecord, :count).by(1)
        .and change { cat.reload.energy_points }.by(1)
    end

    it "目標体重以下を記録するとダイエット挑戦を達成済みにする" do
      weight_record = diet_challenge.weight_records.build(
        weight: diet_challenge.target_weight,
        recorded_on: Date.current
      )

      described_class.new(weight_record).call

      expect(diet_challenge.reload.achieved_at).to be_present
    end

    it "体重記録が無効な場合は保存せず、猫の元気ポイントも増やさない" do
      weight_record = diet_challenge.weight_records.build(
        weight: nil,
        recorded_on: Date.current
      )

      result = described_class.new(weight_record).call

      expect(result).to be false
      expect(weight_record).not_to be_persisted
      expect(cat.reload.energy_points).to eq(0)
    end
  end
end
