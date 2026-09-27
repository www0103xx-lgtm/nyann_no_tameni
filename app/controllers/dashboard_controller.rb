class DashboardController < ApplicationController
  before_action :authenticate_user!

  def show
    @diet_challenge = current_user.diet_challenges
                                  .where(achieved_at: nil)
                                  .order(started_at: :desc, id: :desc)
                                  .first

    unless @diet_challenge
      redirect_to new_diet_challenge_path
      return
    end

    @cat = @diet_challenge.cat
  end
end
