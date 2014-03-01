class AddDescriptionToDelegationFields < ActiveRecord::Migration
  def change
    add_column :delegation_fields, :description, :string
  end
end
