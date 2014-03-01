class CreateDelegationFieldValues < ActiveRecord::Migration
  def change
    create_table :delegation_field_values do |t|
      t.integer :delegation_field_id
      t.text :value
      t.integer :delegation_id
    end

    add_index :delegation_field_values, :delegation_field_id
    add_index :delegation_field_values, :delegation_id
  end
end
