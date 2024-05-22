class AddStartYearAndEndYearToTitles < ActiveRecord::Migration[7.1]
  def change
    add_column :titles, :start_year, :integer
    add_column :titles, :end_year, :integer
  end
end
