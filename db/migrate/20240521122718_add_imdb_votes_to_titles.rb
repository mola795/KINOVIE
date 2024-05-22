class AddImdbVotesToTitles < ActiveRecord::Migration[7.1]
  def change
    add_column :titles, :imdb_votes, :integer
  end
end
