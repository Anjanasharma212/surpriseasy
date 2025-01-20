class CreateAssignments < ActiveRecord::Migration[8.0]
  def change
    create_table :assignments do |t|
      t.integer :giver_id
      t.integer :receiver_id
      t.references :group, null: false, foreign_key: true

      t.timestamps
    end
  end
end
