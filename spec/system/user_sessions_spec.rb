require "rails_helper"

RSpec.describe "ログイン・ログアウト", type: :system do
  let(:user) { create(:user) }

  describe "ログイン" do
    context "入力内容が正常な場合" do
      it "ログインできる" do
        user

        visit new_user_session_path

        fill_in "メールアドレス", with: user.email
        fill_in "パスワード", with: user.password

        click_button "ログイン"

        expect(page).to have_current_path(dashboard_path)
        expect(page).to have_button("ログアウト")
        expect(page).not_to have_link("新規登録")
        expect(page).not_to have_link("ログイン")
      end
    end
  end

  describe "ログアウト" do
    it "ログアウトできる" do
      user

      visit new_user_session_path

      fill_in "メールアドレス", with: user.email
      fill_in "パスワード", with: user.password
      click_button "ログイン"

      click_button "ログアウト"

      expect(page).to have_current_path(root_path)
      expect(page).to have_link("新規登録")
      expect(page).to have_link("ログイン")
      expect(page).not_to have_button("ログアウト")
    end
  end
end
