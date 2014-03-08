class AddPaymentTypeToDelegations < ActiveRecord::Migration
  def change
    add_column :delegations, :payment_type, :string
    change_column :delegation_fields, :description, :text
  end
end
