require "rails_helper"
require "rake"

RSpec.describe "reminder:send_weight_reminders" do
  let(:task_name) { "reminder:send_weight_reminders" }
  let(:task) { Rake::Task[task_name] }

  before(:all) do
    Rake.application.rake_require("tasks/reminder")
    Rake::Task.define_task(:environment)
  end

  before do
    task.reenable
    ActionMailer::Base.deliveries.clear
  end

  let(:user) { create(:user) }
  let(:diet_challenge) { create(:diet_challenge, user: user) }
  let!(:cat) { create(:cat, diet_challenge: diet_challenge) }

  it "当日の体重記録がないユーザーへメールを送信する" do
    expect {
      task.invoke
    }.to change(ActionMailer::Base.deliveries, :count).by(1)

    expect(ActionMailer::Base.deliveries.last.to).to eq([ user.email ])
  end

  it "当日の体重記録があるユーザーへはメールを送信しない" do
    create(
      :weight_record,
      diet_challenge: diet_challenge,
      recorded_on: Date.current
    )

    expect {
      task.invoke
    }.not_to change(ActionMailer::Base.deliveries, :count)
  end

  it "過去の体重記録だけがあるユーザーへはメールを送信する" do
    create(
      :weight_record,
      diet_challenge: diet_challenge,
      recorded_on: Date.current - 1.day
    )

    expect {
      task.invoke
    }.to change(ActionMailer::Base.deliveries, :count).by(1)
  end

  it "終了済みのダイエット挑戦にはメールを送信しない" do
    diet_challenge.update!(achieved_at: Time.current)

    expect {
      task.invoke
    }.not_to change(ActionMailer::Base.deliveries, :count)
  end

  it "複数ユーザーのうち当日の体重記録がないユーザーだけへメールを送信する" do
    recorded_user = create(:user)
    recorded_challenge = create(:diet_challenge, user: recorded_user)
    create(:cat, diet_challenge: recorded_challenge)
    create(
      :weight_record,
      diet_challenge: recorded_challenge,
      recorded_on: Date.current
    )

    expect {
      task.invoke
    }.to change(ActionMailer::Base.deliveries, :count).by(1)

    recipients = ActionMailer::Base.deliveries.flat_map(&:to)

    expect(recipients).to include(user.email)
    expect(recipients).not_to include(recorded_user.email)
  end
end
