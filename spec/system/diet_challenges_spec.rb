require "rails_helper"

RSpec.describe "ダイエット挑戦開始", type: :system do
  let(:user) { create(:user) }

  context "ログインしている場合" do
    it "初期設定画面を表示できる" do
      user

      visit new_user_session_path

      fill_in "メールアドレス", with: user.email
      fill_in "パスワード", with: user.password
      click_button "ログイン"

      expect(page).to have_current_path(dashboard_path)

      visit new_diet_challenge_path

      expect(page).to have_content("にゃんのために。")
      expect(page).to have_field("現在の体重")
      expect(page).to have_field("目標体重")
      expect(page).to have_field("猫の名前")
      expect(page).to have_button("にゃんこのお世話をはじめる。")
    end

    it "ダイエット挑戦を開始できる" do
      user

      visit new_user_session_path

      fill_in "メールアドレス", with: user.email
      fill_in "パスワード", with: user.password
      click_button "ログイン"

      expect(page).to have_current_path(dashboard_path)

      visit new_diet_challenge_path

      fill_in "現在の体重", with: 60.0
      fill_in "目標体重", with: 55.0
      fill_in "猫の名前", with: "ミケ"

      click_button "にゃんこのお世話をはじめる。"

      expect(page).to have_current_path(dashboard_path)

      diet_challenge = user.diet_challenges.last

      expect(diet_challenge).to be_present
      expect(diet_challenge.start_weight).to eq(60.0)
      expect(diet_challenge.target_weight).to eq(55.0)
      expect(diet_challenge.started_at).to eq(Date.current)
      expect(diet_challenge.cat).to be_present
      expect(diet_challenge.cat.name).to eq("ミケ")
      expect(diet_challenge.cat.energy_points).to eq(0)
    end

    it "目標体重が現在の体重以上の場合はダイエット挑戦を開始できない" do
      user

      visit new_user_session_path

      fill_in "メールアドレス", with: user.email
      fill_in "パスワード", with: user.password
      click_button "ログイン"

      expect(page).to have_current_path(dashboard_path)

      visit new_diet_challenge_path

      fill_in "現在の体重", with: 60.0
      fill_in "目標体重", with: 65.0
      fill_in "猫の名前", with: "ミケ"

      click_button "にゃんこのお世話をはじめる。"

      expect(page).to have_content("目標体重は開始体重より小さい値を入力してください")
      expect(page).to have_field("現在の体重", with: "60.0")
      expect(page).to have_field("目標体重", with: "65.0")
      expect(DietChallenge.count).to eq(0)
      expect(Cat.count).to eq(0)
    end
  end
end
