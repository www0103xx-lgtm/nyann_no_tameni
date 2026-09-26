namespace :reminder do
  desc "当日の体重記録がないユーザーへリマインダーメールを送信する"
  task send_weight_reminders: :environment do
    DietChallenge
      .where(achieved_at: nil)
      .includes(:user, :cat, :weight_records)
      .find_each do |diet_challenge|
        next if diet_challenge.weight_records.exists?(recorded_on: Date.current)
        next unless diet_challenge.cat

        ReminderMailer
          .weight_reminder(diet_challenge.user, diet_challenge.cat)
          .deliver_now
      end
  end
end
