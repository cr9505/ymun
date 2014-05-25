class RenamePaymentsMethodToPaymentMethod < ActiveRecord::Migration
  def change
    rename_column :payments, :method, :payment_method
  end
end
