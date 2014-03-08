class AddPaymentCurrencyToDelegations < ActiveRecord::Migration
  def change
    add_column :delegations, :payment_currency, :string
  end
end
