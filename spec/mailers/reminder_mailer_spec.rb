require "rails_helper"

RSpec.describe ReminderMailer, type: :mailer do
  let(:user) { create(:user) }
  let(:diet_challenge) { create(:diet_challenge, user: user) }
  let(:cat) { create(:cat, diet_challenge: diet_challenge, energy_points: 0) }

  describe "#weight_reminder" do
    it "ユーザーのメールアドレス宛てに送信できる" do
      mail = described_class.weight_reminder(user, cat)

      expect(mail.to).to eq([ user.email ])
    end

    it "リマインダーメールの件名が設定される" do
      mail = described_class.weight_reminder(user, cat)

      expect(mail.subject).to eq("【にゃんのために。】今日の体重を記録してね！")
    end

    it "ユーザー名と猫の成長段階が本文に表示される" do
      mail = described_class.weight_reminder(user, cat)

      expect(mail.body.encoded).to include(user.name)
      expect(mail.body.encoded).to include(cat.growth_stage)
    end

    it "猫の成長段階に対応したメッセージが本文に表示される" do
      allow(ReminderMailer::MESSAGES["ガリガリにゃんこ"])
        .to receive(:sample)
        .and_return("テスト用メッセージにゃ")

      mail = described_class.weight_reminder(user, cat)

      expect(mail.body.encoded).to include("テスト用メッセージにゃ")
    end

    it "成長段階に対応する複数のメッセージからランダムで選択する" do
      messages = ReminderMailer::MESSAGES["ガリガリにゃんこ"]

      expect(messages).to receive(:sample).and_call_original

      described_class.weight_reminder(user, cat).body.encoded
    end

    it "リマインダーメールを送信できる" do
      expect {
        described_class.weight_reminder(user, cat).deliver_now
      }.to change(ActionMailer::Base.deliveries, :count).by(1)

      delivered_mail = ActionMailer::Base.deliveries.last

      expect(delivered_mail.to).to eq([ user.email ])
    end
  end
end
