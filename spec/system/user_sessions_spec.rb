require "rails_helper"

RSpec.describe "ログイン・ログアウト", type: :system do
  let(:user) { create(:user) }

  describe "ログイン" do
    context "進行中のダイエット挑戦がない場合" do
      it "ログイン後にダイエット挑戦開始画面へ遷移する" do
        user

        visit new_user_session_path

        fill_in "メールアドレス", with: user.email
        fill_in "パスワード", with: user.password

        click_button "ログイン"

        expect(page).to have_current_path(new_diet_challenge_path)
      end
    end

    context "進行中のダイエット挑戦がある場合" do
      before do
        diet_challenge = create(:diet_challenge, user: user)
        create(:cat, diet_challenge: diet_challenge)
      end

      it "ログイン後にユーザートップへ遷移する" do
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

    context "パスワードが正しくない場合" do
      it "汎用的なエラーメッセージを表示する" do
        user

        visit new_user_session_path

        fill_in "メールアドレス", with: user.email
        fill_in "パスワード", with: "wrong-password"

        click_button "ログイン"

        expect(page).to have_current_path(new_user_session_path)
        expect(page).to have_content("ログインに失敗しました。")
      end
    end

    context "登録されていないメールアドレスの場合" do
      it "同じ汎用的なエラーメッセージを表示する" do
        visit new_user_session_path

        fill_in "メールアドレス", with: "unknown@example.com"
        fill_in "パスワード", with: "password"

        click_button "ログイン"

        expect(page).to have_current_path(new_user_session_path)
        expect(page).to have_content("ログインに失敗しました。")
      end
    end
  end

  describe "ログアウト" do
    it "ログアウトできる" do
      diet_challenge = create(:diet_challenge, user: user)
      create(:cat, diet_challenge: diet_challenge)

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
