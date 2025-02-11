class AddAttributesToItems < ActiveRecord::Migration[8.0]
  def change
    add_column :items, :age, :string
    add_column :items, :gender, :string
    add_column :items, :category, :string
  end
end
