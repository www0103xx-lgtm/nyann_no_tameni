require "rails_helper"

RSpec.describe "体重推移グラフ", type: :system, js: true do
  let(:user) { create(:user) }
  let!(:diet_challenge) { create(:diet_challenge, user: user) }
  let!(:cat) { create(:cat, diet_challenge: diet_challenge) }

  before do
    visit new_user_session_path

    fill_in "メールアドレス", with: user.email
    fill_in "パスワード", with: user.password
    click_button "ログイン"

    expect(page).to have_current_path(dashboard_path)
  end

  it "記録した体重を日付順に確認できる" do
    create(
      :weight_record,
      diet_challenge: diet_challenge,
      weight: 59.0,
      recorded_on: Date.current
    )
    create(
      :weight_record,
      diet_challenge: diet_challenge,
      weight: 60.0,
      recorded_on: Date.current - 2.days
    )
    create(
      :weight_record,
      diet_challenge: diet_challenge,
      weight: 59.5,
      recorded_on: Date.current - 1.day
    )

    visit weight_records_path

    expect(page).to have_content("体重の推移")
    expect(page).to have_content(
      /60\.0.*59\.5.*59\.0/m
    )
  end

  it "折れ線グラフを表示できる" do
    create(
      :weight_record,
      diet_challenge: diet_challenge,
      weight: 60.0,
      recorded_on: Date.current
    )

    visit weight_records_path

    expect(page).to have_css("canvas")
    expect(page).not_to have_content("Loading...")
  end

  it "他のユーザーの体重記録は表示されない" do
    create(
      :weight_record,
      diet_challenge: diet_challenge,
      weight: 60.0,
      recorded_on: Date.current
    )

    other_user = create(:user)
    other_diet_challenge = create(:diet_challenge, user: other_user)
    create(
      :weight_record,
      diet_challenge: other_diet_challenge,
      weight: 99.9,
      recorded_on: Date.current
    )

    visit weight_records_path

    expect(page).to have_content("60.0")
    expect(page).not_to have_content("99.9")
  end

  it "追加した体重記録が反映される" do
    visit weight_records_path

    expect(page).to have_content("体重記録がまだありません")

    create(
      :weight_record,
      diet_challenge: diet_challenge,
      weight: 58.5,
      recorded_on: Date.current
    )

    visit weight_records_path

    expect(page).to have_content("58.5")
    expect(page).to have_css("canvas")
  end

  it "編集した体重記録が反映される" do
    weight_record = create(
      :weight_record,
      diet_challenge: diet_challenge,
      weight: 60.0,
      recorded_on: Date.current
    )

    visit edit_weight_record_path(weight_record)

    fill_in "今日の体重", with: 59.8
    click_button "更新する"

    expect(page).to have_current_path(dashboard_path)

    visit weight_records_path

    expect(page).to have_content("59.8")
    expect(page).not_to have_content("60.0 kg")
  end

  it "体重記録がない場合でも画面を表示できる" do
    visit weight_records_path

    expect(page).to have_content("体重の推移")
    expect(page).to have_content("体重記録がまだありません")
  end
end
