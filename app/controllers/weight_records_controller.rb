class WeightRecordsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_diet_challenge_for_index, only: :index
  before_action :set_current_diet_challenge, only: %i[new create edit update]
  before_action :set_weight_record, only: %i[edit update]

  def index
    @weight_records = @diet_challenge.weight_records.order(:recorded_on)
  end

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

    if save_weight_record_with_energy_point
      redirect_to dashboard_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @weight_record.update(weight_record_params)
      @diet_challenge.achieve_if_target_reached!(@weight_record.weight)
      redirect_to dashboard_path
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_diet_challenge_for_index
    @diet_challenge = current_diet_challenge || latest_achieved_diet_challenge

    return if @diet_challenge

    redirect_to new_diet_challenge_path
  end

  def set_current_diet_challenge
    @diet_challenge = current_diet_challenge

    return if @diet_challenge

    redirect_to dashboard_path
  end

  def current_diet_challenge
    current_user.diet_challenges
                .where(achieved_at: nil)
                .order(started_at: :desc, id: :desc)
                .first
  end

  def latest_achieved_diet_challenge
    current_user.diet_challenges
                .where.not(achieved_at: nil)
                .order(achieved_at: :desc, id: :desc)
                .first
  end

  def set_weight_record
    @weight_record = @diet_challenge.weight_records.find(params[:id])
  end

  def save_weight_record_with_energy_point
    return false unless @weight_record.valid?

    ActiveRecord::Base.transaction do
      @weight_record.save!
      @diet_challenge.cat.increment!(:energy_points)
      @diet_challenge.achieve_if_target_reached!(@weight_record.weight)
    end

    true
  end

  def weight_record_params
    params.require(:weight_record).permit(:weight)
  end
end
