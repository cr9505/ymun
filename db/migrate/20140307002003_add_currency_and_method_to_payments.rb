class AddCurrencyAndMethodToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :currency, :string
    add_column :payments, :method, :string
  end
end
