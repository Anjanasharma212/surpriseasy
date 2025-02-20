class RenameMessageColumnInMessages < ActiveRecord::Migration[8.0]
  def change
    rename_column :messages, :message, :content
  end
end
