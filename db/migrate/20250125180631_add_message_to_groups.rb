class AddMessageToGroups < ActiveRecord::Migration[8.0]
  def change
    add_column :groups, :message, :string
  end
end
