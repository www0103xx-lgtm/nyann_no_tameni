require "rails_helper"

RSpec.describe "ユーザー登録", type: :system do
  describe "新規登録" do
    context "入力内容が正常な場合" do
      it "ユーザー登録できる" do
        visit new_user_registration_path

        fill_in "名前", with: "テストユーザー"
        fill_in "メールアドレス", with: "test@example.com"
        fill_in "パスワード", with: "password"
        fill_in "パスワード確認", with: "password"

        click_button "登録する"

        expect(page).to have_current_path(dashboard_path)
      end
    end
  end
end
