class AddDelegationSizeToDelegations < ActiveRecord::Migration
  def change
    add_column :delegations, :delegation_size, :integer
  end
end
