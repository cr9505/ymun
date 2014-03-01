class CreateCommitteeTypeSelections < ActiveRecord::Migration
  def change
    create_table :committee_type_selections do |t|
      t.integer :committee_type_id
      t.integer :delegation_id
      t.integer :delegate_count

      t.timestamps
    end
  end
end
