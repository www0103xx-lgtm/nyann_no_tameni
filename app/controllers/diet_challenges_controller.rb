class DietChallengesController < ApplicationController
  before_action :authenticate_user!

  def new
    @diet_challenge = current_user.diet_challenges.build
    @diet_challenge.build_cat
  end

  def create
    @diet_challenge = current_user.diet_challenges.build(diet_challenge_params)
    @diet_challenge.started_at = Date.current

    if @diet_challenge.save
      redirect_to dashboard_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def diet_challenge_params
    params.require(:diet_challenge).permit(
      :start_weight,
      :target_weight,
      cat_attributes: [ :name ]
    )
  end
end
