class AddImdbRatingToTitles < ActiveRecord::Migration[7.1]
  def change
    add_column :titles, :imdb_rating, :string
  end
end
