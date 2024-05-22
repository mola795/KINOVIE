class CreateGenres < ActiveRecord::Migration[7.1]
  def change
    create_table :genres do |t|
      t.string :name
      t.integer :tmdb_id
      t.string :cover_url

      t.timestamps
    end
  end
end
