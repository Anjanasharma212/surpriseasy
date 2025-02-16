class CreateParticipants < ActiveRecord::Migration[8.0]
  def change
    create_table :participants do |t|
      t.references :user, null: false, foreign_key: true
      t.references :group, null: false, foreign_key: true
      t.boolean :is_admin, default: false

      t.timestamps
    end
  end
end
