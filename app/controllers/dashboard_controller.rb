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
    @todays_weight_record = @diet_challenge.weight_records.find_by(
      recorded_on: Date.current
    )

    latest_weight_record = @diet_challenge.weight_records
                                            .order(recorded_on: :desc, id: :desc)
                                            .first

    current_weight = latest_weight_record&.weight || @diet_challenge.start_weight
    @remaining_weight = [ current_weight - @diet_challenge.target_weight, 0 ].max
  end
end
