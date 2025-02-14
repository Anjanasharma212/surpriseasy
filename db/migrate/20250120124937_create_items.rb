class CreateItems < ActiveRecord::Migration[8.0]
  def change
    create_table :items do |t|
      t.string :item_name
      t.decimal :price
      t.text :description
      t.string :image_url

      t.timestamps
    end
  end
end
