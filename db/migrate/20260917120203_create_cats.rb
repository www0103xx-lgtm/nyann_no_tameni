class CreateCats < ActiveRecord::Migration[8.1]
  def change
    create_table :cats do |t|
      t.references :diet_challenge, null: false, foreign_key: true, index: { unique: true }
      t.string :name, null: false
      t.integer :energy_points, null: false, default: 0

      t.timestamps
    end
  end
end
