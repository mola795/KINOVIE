class CreateGenreConnections < ActiveRecord::Migration[7.1]
  def change
    create_table :genre_connections do |t|
      t.references :title, null: false, foreign_key: true
      t.references :genre, null: false, foreign_key: true
      t.integer :list_id

      t.timestamps
    end
  end
end
