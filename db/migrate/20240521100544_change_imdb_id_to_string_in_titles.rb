class ChangeImdbIdToStringInTitles < ActiveRecord::Migration[7.1]
  def change
    change_column :titles, :imdb_id, :string
  end
end
