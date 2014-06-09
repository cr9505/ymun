class AddLateRegistrationToDelegations < ActiveRecord::Migration
  def change
    add_column :delegations, :late_delegate_count, :integer
    add_column :delegations, :late_advisor_count, :integer
    add_column :delegations, :is_late_delegation, :boolean
  end
end
