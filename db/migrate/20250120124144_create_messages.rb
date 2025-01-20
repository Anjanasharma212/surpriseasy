class CreateMessages < ActiveRecord::Migration[8.0]
  def change
    create_table :messages do |t|
      t.references :group, null: false, foreign_key: true
      t.integer :sender_id
      t.integer :receiver_id
      t.text :message
      t.boolean :is_anonymous
      t.boolean :read

      t.timestamps
    end
  end
end
