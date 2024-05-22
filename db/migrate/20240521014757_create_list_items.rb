class CreateListItems < ActiveRecord::Migration[7.1]
  def change
    create_table :list_items do |t|
      t.text :comment
      t.references :title, null: false, foreign_key: true
      t.references :list, null: false, foreign_key: true
      t.integer :rank

      t.timestamps
    end
  end
end
