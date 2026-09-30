require "rails_helper"

RSpec.describe "ユーザートップ", type: :system do
  let(:user) { create(:user) }

  context "ログインしている場合" do
    context "ダイエット挑戦が一度もない場合" do
      it "ダイエット挑戦開始画面へ遷移する" do
        user

        visit new_user_session_path

        fill_in "メールアドレス", with: user.email
        fill_in "パスワード", with: user.password
        click_button "ログイン"

        expect(page).to have_current_path(new_diet_challenge_path)
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

      it "ユーザーへの挨拶と案内を表示できる" do
        expect(page).to have_content("#{user.name}さん、こんにちは！")
        expect(page).to have_content("にゃんこと一緒にダイエットをはじめよう！")
      end

      it "体重登録への導線を表示できる" do
        expect(page).to have_link("体重登録", href: new_weight_record_path)
      end

      it "これまでの記録への導線を表示できる" do
        expect(page).to have_link("これまでの記録", href: weight_records_path)
      end

      context "今日の体重をまだ記録していない場合" do
        it "体重記録を促すメッセージを表示できる" do
          expect(page).to have_content("今日の体重を記録してね！")
          expect(page).not_to have_content(
            "体重記録ありがとう！また明日も会いに来てね！"
          )
        end

        it "開始体重を基準に目標体重までの残りを表示できる" do
          expect(page).to have_content("目標体重まであと5.0kg！！")
        end
      end

      context "今日の体重を記録済みの場合" do
        before do
          create(
            :weight_record,
            diet_challenge: diet_challenge,
            weight: 58.2,
            recorded_on: Date.current
          )

          visit dashboard_path
        end

        it "体重記録へのお礼メッセージを表示できる" do
          expect(page).to have_content(
            "体重記録ありがとう！また明日も会いに来てね！"
          )
          expect(page).not_to have_content("今日の体重を記録してね！")
        end

        it "最新の体重を基準に目標体重までの残りを表示できる" do
          expect(page).to have_content("目標体重まであと3.2kg！！")
        end
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

      it "成長段階が変わると表示される猫も切り替わる" do
        expect(page).to have_css('img[src*="cats/skinny"]', visible: true)

        cat.update!(energy_points: 21)

        visit dashboard_path

        expect(page).to have_css('img[src*="cats/slim"]', visible: true)
        expect(page).not_to have_css('img[src*="cats/skinny"]', visible: true)
      end
    end

    context "達成済みのダイエット挑戦がある場合" do
      let!(:diet_challenge) do
        create(
          :diet_challenge,
          user: user,
          start_weight: 60.0,
          target_weight: 55.0,
          achieved_at: Time.current
        )
      end

      let!(:cat) do
        create(
          :cat,
          diet_challenge: diet_challenge,
          energy_points: 10
        )
      end

      before do
        visit new_user_session_path

        fill_in "メールアドレス", with: user.email
        fill_in "パスワード", with: user.password
        click_button "ログイン"
      end

      it "達成後もダッシュボードを表示する" do
        expect(page).to have_current_path(dashboard_path)
        expect(page).to have_content("目標達成おめでとう！")
      end

      it "まん丸にゃんこと達成メッセージを表示する" do
        expect(page).to have_css(
          'img[src*="cats/round"]',
          visible: true
        )
        expect(page).to have_content("目標達成！しあわせにゃ！")
      end

      it "次のにゃんこをお世話する導線を表示する" do
        expect(page).to have_link(
          "次のにゃんこをお世話する",
          href: new_diet_challenge_path
        )
      end

      it "これまでの記録への導線を表示する" do
        expect(page).to have_link(
          "これまでの記録",
          href: weight_records_path
        )
      end

      it "体重登録への導線と体重記録を促すメッセージを表示しない" do
        expect(page).not_to have_link("体重登録")
        expect(page).not_to have_content("今日の体重を記録してね！")
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
