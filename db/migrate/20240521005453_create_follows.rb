class CreateFollows < ActiveRecord::Migration[7.1]
  def change
    create_table :follows do |t|
      t.integer :follower_id
      t.integer :followed_id
      t.datetime :created_at

      t.timestamps
    end
  end
end
