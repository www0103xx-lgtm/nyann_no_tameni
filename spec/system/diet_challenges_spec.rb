require "rails_helper"

RSpec.describe "ダイエット挑戦開始", type: :system do
  let(:user) { create(:user) }

  context "ログインしている場合" do
    before do
      visit new_user_session_path

      fill_in "メールアドレス", with: user.email
      fill_in "パスワード", with: user.password
      click_button "ログイン"

      expect(page).to have_current_path(new_diet_challenge_path)
    end

    it "見出しからトップページへ戻れる" do
      expect(page).to have_link("にゃんのために。", href: root_path)

      click_link "にゃんのために。"

      expect(page).to have_current_path(root_path)
    end

    it "初期設定画面を表示できる" do
      expect(page).to have_content("にゃんのために。")
      expect(page).to have_field("現在の体重")
      expect(page).to have_field("目標体重")
      expect(page).to have_field("猫の名前")
      expect(page).to have_button("にゃんこのお世話をはじめる。")
    end

    it "ダイエット挑戦を開始できる" do
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

  context "進行中のダイエット挑戦がある場合" do
    let!(:diet_challenge) do
      create(
        :diet_challenge,
        user: user,
        start_weight: 60.0,
        target_weight: 55.0
      )
    end

    let!(:cat) do
      create(
        :cat,
        diet_challenge: diet_challenge,
        name: "ミケ"
      )
    end

    it "新しいダイエット挑戦開始画面へ直接アクセスしてもダッシュボードへ戻る" do
      visit new_user_session_path

      fill_in "メールアドレス", with: user.email
      fill_in "パスワード", with: user.password
      click_button "ログイン"

      expect(page).to have_current_path(dashboard_path)

      visit new_diet_challenge_path

      expect(page).to have_current_path(dashboard_path)
      expect(user.diet_challenges.count).to eq(1)
    end
  end

  context "達成済みのダイエット挑戦がある場合" do
    let!(:achieved_diet_challenge) do
      create(
        :diet_challenge,
        user: user,
        start_weight: 60.0,
        target_weight: 55.0,
        achieved_at: Time.current
      )
    end

    let!(:previous_cat) do
      create(
        :cat,
        diet_challenge: achieved_diet_challenge,
        name: "ミケ"
      )
    end

    it "前の挑戦と猫を残したまま新しいにゃんこのお世話を始められる" do
      visit new_user_session_path

      fill_in "メールアドレス", with: user.email
      fill_in "パスワード", with: user.password
      click_button "ログイン"

      expect(page).to have_current_path(dashboard_path)
      expect(page).to have_link("次のにゃんこをお世話する")

      click_link "次のにゃんこをお世話する"

      expect(page).to have_current_path(new_diet_challenge_path)

      fill_in "現在の体重", with: 58.0
      fill_in "目標体重", with: 56.0
      fill_in "猫の名前", with: "ハチ"

      click_button "にゃんこのお世話をはじめる。"

      expect(page).to have_current_path(dashboard_path)

      expect(user.diet_challenges.count).to eq(2)

      new_diet_challenge = user.diet_challenges
                               .where(achieved_at: nil)
                               .order(id: :desc)
                               .first

      expect(new_diet_challenge).to be_present
      expect(new_diet_challenge.start_weight).to eq(58.0)
      expect(new_diet_challenge.target_weight).to eq(56.0)
      expect(new_diet_challenge.cat.name).to eq("ハチ")

      expect(achieved_diet_challenge.reload.achieved_at).to be_present
      expect(achieved_diet_challenge.cat).to eq(previous_cat)
      expect(previous_cat.reload.name).to eq("ミケ")
    end
  end
end
