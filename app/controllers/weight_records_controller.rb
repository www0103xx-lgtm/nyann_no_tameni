class WeightRecordsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_current_diet_challenge
  before_action :set_weight_record, only: %i[edit update]

  def new
    todays_record = @diet_challenge.weight_records.find_by(recorded_on: Date.current)

    if todays_record
      redirect_to edit_weight_record_path(todays_record)
      return
    end

    @weight_record = @diet_challenge.weight_records.build
  end

  def create
    @weight_record = @diet_challenge.weight_records.build(weight_record_params)
    @weight_record.recorded_on = Date.current

    if @weight_record.save
      redirect_to dashboard_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @weight_record.update(weight_record_params)
      redirect_to dashboard_path
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_current_diet_challenge
    @diet_challenge = current_user.diet_challenges
                                  .where(achieved_at: nil)
                                  .order(started_at: :desc, id: :desc)
                                  .first

    return if @diet_challenge

    redirect_to new_diet_challenge_path
  end

  def set_weight_record
    @weight_record = @diet_challenge.weight_records.find(params[:id])
  end

  def weight_record_params
    params.require(:weight_record).permit(:weight)
  end
end
