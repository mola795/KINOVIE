class AddListIdToGenreConnections < ActiveRecord::Migration[7.1]
  def change
    change_column_null :genre_connections, :title_id, true
  end
end
