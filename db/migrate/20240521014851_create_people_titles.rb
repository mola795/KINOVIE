class CreatePeopleTitles < ActiveRecord::Migration[7.1]
  def change
    create_table :people_titles do |t|
      t.references :title, null: false, foreign_key: true
      t.references :person, null: false, foreign_key: true

      t.timestamps
    end
  end
end
