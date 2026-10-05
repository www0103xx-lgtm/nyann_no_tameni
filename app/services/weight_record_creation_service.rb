class WeightRecordCreationService
  def initialize(weight_record)
    @weight_record = weight_record
  end

  def call
    return false unless @weight_record.valid?

    ActiveRecord::Base.transaction do
      @weight_record.save!
      @weight_record.diet_challenge.cat.increment!(:energy_points)
      @weight_record.diet_challenge.achieve_if_target_reached!(@weight_record.weight)
    end

    true
  end
end
