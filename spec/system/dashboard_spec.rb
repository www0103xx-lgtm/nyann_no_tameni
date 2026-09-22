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

    context "猫がいる場合" do
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
          energy_points: 0
        )
      end

      before do
        visit new_user_session_path

        fill_in "メールアドレス", with: user.email
        fill_in "パスワード", with: user.password
        click_button "ログイン"

        expect(page).to have_current_path(dashboard_path)
      end

      it "ガリガリにゃんこを表示できる" do
        expect(page).to have_css(
          'img[src*="cats/skinny"]',
          visible: true
        )
        expect(page).to have_content("お腹すいたにゃ……")
        expect(page).to have_content("現在のpt：0pt")
      end

      it "痩せ気味にゃんこを表示できる" do
        cat.update!(energy_points: 21)

        visit dashboard_path

        expect(page).to have_css(
          'img[src*="cats/slim"]',
          visible: true
        )
        expect(page).to have_content("少し元気になってきたにゃ！")
        expect(page).to have_content("現在のpt：21pt")
      end

      it "普通にゃんこを表示できる" do
        cat.update!(energy_points: 51)

        visit dashboard_path

        expect(page).to have_css(
          'img[src*="cats/normal"]',
          visible: true
        )
        expect(page).to have_content("元気いっぱいにゃ！")
        expect(page).to have_content("現在のpt：51pt")
      end

      it "目標体重を達成するとまん丸にゃんこを表示できる" do
        create(
          :weight_record,
          diet_challenge: diet_challenge,
          weight: 55.0,
          recorded_on: Date.current
        )

        visit dashboard_path

        expect(page).to have_css(
          'img[src*="cats/round"]',
          visible: true
        )
        expect(page).to have_content("目標達成！しあわせにゃ！")
        expect(page).to have_content("現在のpt：0pt")
      end

      it "成長段階が変わると表示される猫も切り替わる" do
        expect(page).to have_css('img[src*="cats/skinny"]', visible: true)

        cat.update!(energy_points: 21)

        visit dashboard_path

        expect(page).to have_css('img[src*="cats/slim"]', visible: true)
        expect(page).not_to have_css('img[src*="cats/skinny"]', visible: true)
      end
    end
  end

  context "ログインしていない場合" do
    it "ログイン画面へ遷移する" do
      visit dashboard_path

      expect(page).to have_current_path(new_user_session_path)
    end
  end
end
