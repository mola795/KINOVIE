class CreateLists < ActiveRecord::Migration[7.1]
  def change
    create_table :lists do |t|
      t.string :name
      t.references :user, null: false, foreign_key: true
      t.datetime :created_at
      t.datetime :updated_at
      t.text :description
      t.string :status
      t.integer :genre_id
      t.string :cover_url

      t.timestamps
    end
  end
end
