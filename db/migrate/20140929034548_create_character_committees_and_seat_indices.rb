class CreateCharacterCommitteesAndSeatIndices < ActiveRecord::Migration
  def change
    create_table :character_committees do |t|
      t.integer :character_id
      t.integer :committee_id
    end

    add_index :character_committees, :character_id
    add_index :character_committees, :committee_id

    remove_column :characters, :committee_id

    add_column :characters, :seat_index, :integer
  end
end
