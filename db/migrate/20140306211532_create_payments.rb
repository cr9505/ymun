class CreatePayments < ActiveRecord::Migration
  def change
    create_table :payments do |t|
      t.integer :delegation_id
      t.string :payer_id
      t.string :payment_id
      t.float :amount
      t.string :sale_id
      t.string :state
    end
  end
end
