class AddWarningsToDelegations < ActiveRecord::Migration
  def change
    add_column :delegations, :warnings, :text, array: true
  end
end
