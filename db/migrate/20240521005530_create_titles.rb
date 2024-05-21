class CreateTitles < ActiveRecord::Migration[7.1]
  def change
    create_table :titles do |t|
      t.string :name
      t.string :media_type
      t.date :release_date
      t.integer :tmdb_id
      t.integer :imdb_id
      t.datetime :created_at
      t.datetime :updated_at
      t.string :poster_url

      t.timestamps
    end
  end
end
