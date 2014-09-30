class CreateSeats < ActiveRecord::Migration
  def change
    create_table :seats do |t|
      t.integer :delegation_id, index: true
      t.integer :character_id, index: true
      t.integer :country_committee_id, index: true
      t.integer :delegate_id, index: true

      t.timestamps
    end

    rename_column :characters, :seat_index, :seat_count
  end
end
