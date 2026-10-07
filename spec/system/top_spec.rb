require "rails_helper"

RSpec.describe "トップページ", type: :system do
  let(:user) { create(:user) }

  context "未ログインの場合" do
    it "トップページを表示する" do
      visit root_path

      expect(page).to have_current_path(root_path)
      expect(page).to have_content("にゃんのために。")
      expect(page).to have_link("新規登録")
      expect(page).to have_link("ログイン")
      expect(page).not_to have_link("ユーザートップ")
      expect(page).not_to have_button("ログアウト")
    end
  end

  context "ログイン済みの場合" do
    before do
      diet_challenge = create(:diet_challenge, user: user)
      create(:cat, diet_challenge: diet_challenge)

      visit new_user_session_path

      fill_in "メールアドレス", with: user.email
      fill_in "パスワード", with: user.password
      click_button "ログイン"

      expect(page).to have_current_path(dashboard_path)
    end

    it "トップページを表示し、ログイン済みユーザー向けの導線を表示する" do
      visit root_path

      expect(page).to have_current_path(root_path)
      expect(page).to have_content("にゃんのために。")
      expect(page).to have_link("ユーザートップ", href: dashboard_path)
      expect(page).to have_button("ログアウト")
      expect(page).not_to have_link("新規登録")
      expect(page).not_to have_link("ログイン")
    end

    it "ユーザートップからダッシュボードへ戻れる" do
      visit root_path

      click_link "ユーザートップ"

      expect(page).to have_current_path(dashboard_path)
    end
  end
end
