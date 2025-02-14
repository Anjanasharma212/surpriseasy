class CreateGroups < ActiveRecord::Migration[8.0]
  def change
    create_table :groups do |t|
      t.string :group_name
      t.references :user, null: false, foreign_key: true
      t.decimal :budget
      t.string :event_name
      t.datetime :event_date
      t.string :group_code

      t.timestamps
    end
  end
end
