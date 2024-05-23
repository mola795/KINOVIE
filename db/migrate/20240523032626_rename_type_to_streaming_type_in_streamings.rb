class RenameTypeToStreamingTypeInStreamings < ActiveRecord::Migration[7.1]
  def change
    rename_column :streamings, :type, :streaming_type
  end
end
