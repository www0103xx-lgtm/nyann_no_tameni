class CreateWeightRecords < ActiveRecord::Migration[8.1]
  def change
    create_table :weight_records do |t|
      t.references :diet_challenge, null: false, foreign_key: true
      t.decimal :weight, precision: 5, scale: 1, null: false
      t.date :recorded_on, null: false

      t.timestamps
    end

    add_index :weight_records, [ :diet_challenge_id, :recorded_on ], unique: true
  end
end
