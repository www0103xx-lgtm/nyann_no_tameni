class DashboardController < ApplicationController
  before_action :authenticate_user!

  def show
    @diet_challenge = current_user.diet_challenges
                                  .where(achieved_at: nil)
                                  .order(started_at: :desc, id: :desc)
                                  .first
    @cat = @diet_challenge&.cat
  end
end
