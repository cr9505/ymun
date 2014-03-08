class Payment < ActiveRecord::Base
  default_scope -> { order 'updated_at' }
  def self.new_from_payment(payment)
    self.new(payment_id: payment.id, 
             state: payment.state, 
             amount: payment.transactions.map{|t|t.amount.total.to_f}.sum,
             currency: 'usd',
             method: 'paypal'
             )
  end
end