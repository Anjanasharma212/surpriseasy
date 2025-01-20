class CreateNotifications < ActiveRecord::Migration[8.0]
  def change
    create_table :notifications do |t|
      t.references :notifiable, polymorphic: true, null: false
      t.references :user, null: false, foreign_key: true
      t.text :message
      t.string :notification_type
      t.boolean :is_read

      t.timestamps
    end
  end
end
