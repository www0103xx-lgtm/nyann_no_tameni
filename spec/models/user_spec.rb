require "rails_helper"

RSpec.describe User, type: :model do
  describe "バリデーション" do
    context "登録できる場合" do
      it "名前、メールアドレス、パスワード、パスワード確認があれば有効である" do
        user = build(:user)

        expect(user).to be_valid
      end
    end

    context "登録できない場合" do
      it "名前が空の場合は無効である" do
        user = build(:user, name: nil)

        expect(user).to be_invalid
        expect(user.errors[:name]).to be_present
      end

      it "メールアドレスが空の場合は無効である" do
        user = build(:user, email: nil)

        expect(user).to be_invalid
        expect(user.errors[:email]).to be_present
      end

      it "メールアドレスが重複している場合は無効である" do
        user = create(:user)
        another_user = build(:user, email: user.email)

        expect(another_user).to be_invalid
        expect(another_user.errors[:email]).to be_present
      end

      it "パスワードが空の場合は無効である" do
        user = build(:user, password: nil, password_confirmation: nil)

        expect(user).to be_invalid
        expect(user.errors[:password]).to be_present
      end

      it "パスワードが6文字未満の場合は無効である" do
        user = build(:user, password: "12345", password_confirmation: "12345")

        expect(user).to be_invalid
        expect(user.errors[:password]).to be_present
      end

      it "パスワードとパスワード確認が一致しない場合は無効である" do
        user = build(
          :user,
          password: "password",
          password_confirmation: "different"
        )

        expect(user).to be_invalid
        expect(user.errors[:password_confirmation]).to be_present
      end
    end
  end
end
