class CreateDietChallenges < ActiveRecord::Migration[8.1]
  def change
    create_table :diet_challenges do |t|
      t.references :user, null: false, foreign_key: true
      t.decimal :start_weight, precision: 5, scale: 1, null: false
      t.decimal :target_weight, precision: 5, scale: 1, null: false
      t.date :started_at, null: false
      t.date :achieved_at

      t.timestamps
    end
  end
end
