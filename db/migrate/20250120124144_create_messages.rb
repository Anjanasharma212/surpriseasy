class CreateMessages < ActiveRecord::Migration[8.0]
  def change
    create_table :messages do |t|
      t.references :group, null: false, foreign_key: true
      t.references :sender, null: false, foreign_key: { to_table: :users }, type: :bigint
      
      t.text :message, null: false
      t.boolean :is_anonymous, default: false
      t.boolean :read, default: false

      t.timestamps
    end
  end
end
