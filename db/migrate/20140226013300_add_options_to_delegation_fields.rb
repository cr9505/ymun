class AddOptionsToDelegationFields < ActiveRecord::Migration
  def change
    add_column :delegation_fields, :options, :string
  end
end
