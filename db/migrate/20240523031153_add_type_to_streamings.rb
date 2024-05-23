class AddTypeToStreamings < ActiveRecord::Migration[7.1]
  def change
    add_column :streamings, :type, :string
  end
end
