class AddDrawnNameToParticipants < ActiveRecord::Migration[8.0]
  def change
    add_reference :participants, :drawn_name, foreign_key: { to_table: :participants }
  end
end
