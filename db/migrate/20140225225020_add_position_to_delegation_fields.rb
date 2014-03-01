class AddPositionToDelegationFields < ActiveRecord::Migration
  def change
    add_column :delegation_fields, :position, :integer
  end
end
