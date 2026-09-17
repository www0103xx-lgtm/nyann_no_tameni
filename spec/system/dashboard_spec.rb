require "rails_helper"

RSpec.describe "ユーザートップ", type: :system do
  let(:user) { create(:user) }

  context "ログインしている場合" do
    it "ユーザートップを表示できる" do
      user

      visit new_user_session_path

      fill_in "メールアドレス", with: user.email
      fill_in "パスワード", with: user.password
      click_button "ログイン"

      expect(page).to have_current_path(dashboard_path)
      expect(page).to have_content("#{user.name}さん、こんにちは！")
      expect(page).to have_content("にゃんこと一緒にダイエットをはじめよう！")
      expect(page).to have_button("ログアウト")
    end
  end

  context "ログインしていない場合" do
    it "ログイン画面へ遷移する" do
      visit dashboard_path

      expect(page).to have_current_path(new_user_session_path)
    end
  end
end
