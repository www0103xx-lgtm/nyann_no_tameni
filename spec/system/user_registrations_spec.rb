require "rails_helper"

RSpec.describe "ユーザー登録", type: :system do
  describe "新規登録" do
    it "見出しからトップページへ戻れる" do
      visit new_user_registration_path

      expect(page).to have_link("にゃんのために。", href: root_path)

      click_link "にゃんのために。"

      expect(page).to have_current_path(root_path)
    end

    context "入力内容が正常な場合" do
      it "ユーザー登録後にダイエット挑戦開始画面へ遷移し、登録完了メッセージを表示する" do
        visit new_user_registration_path

        fill_in "名前", with: "テストユーザー"
        fill_in "メールアドレス", with: "test@example.com"
        fill_in "パスワード", with: "password"
        fill_in "パスワード確認", with: "password"

        click_button "登録する"

        expect(page).to have_current_path(new_diet_challenge_path)
        expect(page).to have_content("新規登録が完了しました。")
        expect(page).not_to have_content("Translation missing")
      end
    end

    context "登録済みのメールアドレスを入力した場合" do
      it "アカウントの存在を推測できるエラーメッセージを表示しない" do
        create(:user, email: "registered@example.com")

        visit new_user_registration_path

        fill_in "名前", with: "テストユーザー"
        fill_in "メールアドレス", with: "registered@example.com"
        fill_in "パスワード", with: "password"
        fill_in "パスワード確認", with: "password"

        click_button "登録する"

        expect(page).to have_content("登録できませんでした。入力内容をご確認ください。")
        expect(page).not_to have_content("すでに存在します")
        expect(page).not_to have_content("Translation missing")
        expect(page).not_to have_content("*パスワード確認を入力してください")
      end
    end

    context "必須項目が空欄の場合" do
      it "各項目のエラーメッセージを表示する" do
        visit new_user_registration_path

        click_button "登録する"

        expect(page).to have_content("*名前を入力してください")
        expect(page).to have_content("*メールアドレスを入力してください")
        expect(page).to have_content("*パスワードを入力してください")
        expect(page).to have_content("*パスワード確認を入力してください")
        expect(page).not_to have_content("Translation missing")
      end
    end

    context "パスワードが短い場合" do
      it "パスワードの文字数に関するエラーメッセージを表示する" do
        visit new_user_registration_path

        fill_in "名前", with: "テストユーザー"
        fill_in "メールアドレス", with: "test@example.com"
        fill_in "パスワード", with: "12345"
        fill_in "パスワード確認", with: "12345"

        click_button "登録する"

        expect(page).to have_content("*パスワードは6文字以上で入力してください")
      end
    end

    context "パスワード確認が空欄の場合" do
      it "パスワード確認の入力を促すエラーメッセージを表示する" do
        visit new_user_registration_path

        fill_in "名前", with: "テストユーザー"
        fill_in "メールアドレス", with: "test@example.com"
        fill_in "パスワード", with: "password"

        click_button "登録する"

        expect(page).to have_content("*パスワード確認を入力してください")
        expect(page).not_to have_content("*パスワードが一致していません")
      end
    end

    context "パスワード確認が一致しない場合" do
      it "パスワード不一致のエラーメッセージを表示する" do
        visit new_user_registration_path

        fill_in "名前", with: "テストユーザー"
        fill_in "メールアドレス", with: "test@example.com"
        fill_in "パスワード", with: "password"
        fill_in "パスワード確認", with: "password2"

        click_button "登録する"

        expect(page).to have_content("*パスワードが一致していません")
        expect(page).not_to have_content("*パスワード確認を入力してください")
      end
    end
  end
end
