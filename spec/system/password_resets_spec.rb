require "rails_helper"

RSpec.describe "パスワード再設定", type: :system do
  describe "パスワード再設定メール送信画面" do
    it "日本語で表示される" do
      visit new_user_password_path

      expect(page).to have_content("パスワードをお忘れですか？")
      expect(page).to have_field("メールアドレス")
      expect(page).to have_button("パスワード再設定メールを送信")
      expect(page).not_to have_content("Forgot your password?")
      expect(page).not_to have_button("Send me password reset instructions")
    end

    context "登録されているメールアドレスの場合" do
      let!(:user) { create(:user) }

      it "汎用的な案内メッセージを表示する" do
        visit new_user_password_path

        fill_in "メールアドレス", with: user.email
        click_button "パスワード再設定メールを送信"

        expect(page).to have_current_path(new_user_session_path)
        expect(page).to have_content(
          "パスワード再設定用の案内を送信しました。メールをご確認ください。"
        )
      end
    end

    context "登録されていないメールアドレスの場合" do
      it "登録済みの場合と同じ案内メッセージを表示する" do
        visit new_user_password_path

        fill_in "メールアドレス", with: "unknown@example.com"
        click_button "パスワード再設定メールを送信"

        expect(page).to have_current_path(new_user_session_path)
        expect(page).to have_content(
          "パスワード再設定用の案内を送信しました。メールをご確認ください。"
        )
        expect(page).not_to have_content("Translation missing")
        expect(page).not_to have_content("見つかりません")
      end
    end
  end

  describe "パスワードの再設定" do
    let!(:user) { create(:user) }

    it "再設定メールの件名と本文が日本語で表示される" do
      user.send_reset_password_instructions

      mail = ActionMailer::Base.deliveries.last

      expect(mail.subject).to eq("パスワード再設定のご案内")
      expect(mail.body.decoded).to include(
        "パスワード再設定のリクエストを受け付けました。"
      )
      expect(mail.body.decoded).to include("パスワードを再設定する")
      expect(mail.body.decoded).not_to include("Reset password instructions")
      expect(mail.body.decoded).not_to include("Change my password")
    end

    it "再設定リンクから新しいパスワードに変更できる" do
      reset_password_token = user.send_reset_password_instructions

      visit edit_user_password_path(reset_password_token: reset_password_token)

      expect(page).to have_content("パスワードを再設定")
      expect(page).to have_field("新しいパスワード")
      expect(page).to have_field("新しいパスワード（確認）")
      expect(page).to have_button("パスワードを変更")
      expect(page).not_to have_content("Change your password")

      fill_in "新しいパスワード", with: "newpassword123"
      fill_in "新しいパスワード（確認）", with: "newpassword123"
      click_button "パスワードを変更"

      visit new_user_session_path

      fill_in "メールアドレス", with: user.email
      fill_in "パスワード", with: "newpassword123"
      click_button "ログイン"

      expect(page).to have_current_path(new_diet_challenge_path)
    end

    it "パスワードが一致しない場合は分かりやすいエラーメッセージを表示する" do
      reset_password_token = user.send_reset_password_instructions

      visit edit_user_password_path(reset_password_token: reset_password_token)

      fill_in "新しいパスワード", with: "password123"
      fill_in "新しいパスワード（確認）", with: "password456"
      click_button "パスワードを変更"

      expect(page).to have_content(
        "パスワードが一致しませんでした。もう一度やり直してください"
      )
      expect(page).not_to have_content(
        "エラーが発生したためユーザーを保存できませんでした"
      )
      expect(page).not_to have_content("Password confirmation")
      expect(page).not_to have_content("Translation missing")
    end
  end
end
