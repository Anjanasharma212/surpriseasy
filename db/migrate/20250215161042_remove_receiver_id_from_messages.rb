class RemoveReceiverIdFromMessages < ActiveRecord::Migration[8.0]
  def change
    remove_column :messages, :receiver_id, :integer
  end
end
