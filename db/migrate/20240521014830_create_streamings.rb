class CreateStreamings < ActiveRecord::Migration[7.1]
  def change
    create_table :streamings do |t|
      t.references :title, null: false, foreign_key: true
      t.references :service, null: false, foreign_key: true
      t.string :url

      t.timestamps
    end
  end
end
