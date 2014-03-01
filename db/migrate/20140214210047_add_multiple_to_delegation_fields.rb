class AddMultipleToDelegationFields < ActiveRecord::Migration
  def change
    add_column :delegation_fields, :multiple, :boolean
    add_column :delegation_fields, :active, :boolean
  end
end
