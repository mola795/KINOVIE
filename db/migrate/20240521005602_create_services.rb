class CreateServices < ActiveRecord::Migration[7.1]
  def change
    create_table :services do |t|
      t.string :name
      t.integer :watchmode_id
      t.datetime :created_at
      t.datetime :updated_at

      t.timestamps
    end
  end
end
