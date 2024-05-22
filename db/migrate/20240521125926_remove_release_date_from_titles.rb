class RemoveReleaseDateFromTitles < ActiveRecord::Migration[7.1]
  def change
    remove_column :titles, :release_date, :date
  end
end
