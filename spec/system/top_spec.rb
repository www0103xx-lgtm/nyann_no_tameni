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
    end
  end

  context "ログイン済みの場合" do
    it "トップページにアクセスするとダッシュボードへ遷移する" do
      diet_challenge = create(:diet_challenge, user: user)
      create(:cat, diet_challenge: diet_challenge)

      visit new_user_session_path

      fill_in "メールアドレス", with: user.email
      fill_in "パスワード", with: user.password
      click_button "ログイン"

      expect(page).to have_current_path(dashboard_path)
      expect(page).to have_button("ログアウト")

      visit root_path

      expect(page).to have_current_path(dashboard_path)
      expect(page).to have_button("ログアウト")
    end
  end
end
