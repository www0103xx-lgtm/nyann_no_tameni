require "rails_helper"

RSpec.describe "体重記録", type: :system do
  let(:user) { create(:user) }
  let!(:diet_challenge) { create(:diet_challenge, user: user) }

  it "体重記録画面を表示できる" do
    visit new_user_session_path

    fill_in "メールアドレス", with: user.email
    fill_in "パスワード", with: user.password
    click_button "ログイン"

    expect(page).to have_current_path(dashboard_path)

    visit new_weight_record_path

    expect(page).to have_content("今日の体重を記録")
    expect(page).to have_field("今日の体重")
    expect(page).to have_button("記録する")
  end

  it "今日の体重を現在のダイエット挑戦に紐づけて記録できる" do
    visit new_user_session_path

    fill_in "メールアドレス", with: user.email
    fill_in "パスワード", with: user.password
    click_button "ログイン"

    expect(page).to have_current_path(dashboard_path)

    visit new_weight_record_path

    fill_in "今日の体重", with: 60.0
    click_button "記録する"

    expect(page).to have_current_path(dashboard_path)

    weight_record = diet_challenge.weight_records.last

    expect(weight_record).to be_present
    expect(weight_record.weight).to eq(60.0)
    expect(weight_record.recorded_on).to eq(Date.current)
    expect(weight_record.diet_challenge).to eq(diet_challenge)
  end

  it "今日の体重を記録済みの場合は編集画面を表示する" do
    weight_record = create(
      :weight_record,
      diet_challenge: diet_challenge,
      weight: 60.0,
      recorded_on: Date.current
    )

    visit new_user_session_path

    fill_in "メールアドレス", with: user.email
    fill_in "パスワード", with: user.password
    click_button "ログイン"

    expect(page).to have_current_path(dashboard_path)

    visit new_weight_record_path

    expect(page).to have_current_path(edit_weight_record_path(weight_record))
    expect(page).to have_content("今日の体重を編集")
    expect(page).to have_field("今日の体重", with: "60.0")
    expect(page).to have_button("更新する")
  end

  it "今日の体重を何度でも上書きできる" do
    weight_record = create(
      :weight_record,
      diet_challenge: diet_challenge,
      weight: 60.0,
      recorded_on: Date.current
    )

    visit new_user_session_path

    fill_in "メールアドレス", with: user.email
    fill_in "パスワード", with: user.password
    click_button "ログイン"

    expect(page).to have_current_path(dashboard_path)

    visit edit_weight_record_path(weight_record)

    fill_in "今日の体重", with: 59.8
    click_button "更新する"

    expect(page).to have_current_path(dashboard_path)

    weight_record.reload

    expect(weight_record.weight).to eq(59.8)
    expect(diet_challenge.weight_records.count).to eq(1)
  end

  it "不正な体重の場合は記録できない" do
    visit new_user_session_path

    fill_in "メールアドレス", with: user.email
    fill_in "パスワード", with: user.password
    click_button "ログイン"

    expect(page).to have_current_path(dashboard_path)

    visit new_weight_record_path

    fill_in "今日の体重", with: ""
    click_button "記録する"

    expect(page).to have_content("体重を入力してください")
    expect(diet_challenge.weight_records.count).to eq(0)
  end

  it "不正な体重の場合は更新できない" do
    weight_record = create(
      :weight_record,
      diet_challenge: diet_challenge,
      weight: 60.0,
      recorded_on: Date.current
    )

    visit new_user_session_path

    fill_in "メールアドレス", with: user.email
    fill_in "パスワード", with: user.password
    click_button "ログイン"

    expect(page).to have_current_path(dashboard_path)

    visit edit_weight_record_path(weight_record)

    fill_in "今日の体重", with: ""
    click_button "更新する"

    expect(page).to have_content("体重を入力してください")

    weight_record.reload

    expect(weight_record.weight).to eq(60.0)
  end

  it "他のユーザーの体重記録は編集できない" do
    other_user = create(:user)
    other_diet_challenge = create(:diet_challenge, user: other_user)
    other_weight_record = create(
      :weight_record,
      diet_challenge: other_diet_challenge,
      weight: 55.0,
      recorded_on: Date.current
    )

    visit new_user_session_path

    fill_in "メールアドレス", with: user.email
    fill_in "パスワード", with: user.password
    click_button "ログイン"

    expect(page).to have_current_path(dashboard_path)

    visit edit_weight_record_path(other_weight_record)

    expect(page).to have_content("ActiveRecord::RecordNotFound")
    expect(page).not_to have_content("今日の体重を編集")
  end
end
