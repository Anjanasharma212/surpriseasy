class UpdateParticipantsDrawnName < ActiveRecord::Migration[8.0]
  def change
    remove_foreign_key :participants, column: :drawn_name_id, if_exists: true
  end
end
