class AddStepToDelegations < ActiveRecord::Migration
  def change
    add_column :delegations, :step, :integer

    remove_column :delegation_pages, :order
    add_column :delegation_pages, :step, :integer
  end
end
