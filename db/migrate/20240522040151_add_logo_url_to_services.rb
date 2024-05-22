class AddLogoUrlToServices < ActiveRecord::Migration[7.1]
  def change
    add_column :services, :logo_url, :string
  end
end
