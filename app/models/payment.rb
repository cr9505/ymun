class Payment < ActiveRecord::Base
  default_scope -> { order 'updated_at' }

  belongs_to :delegation
  validates_associated :delegation

  def self.approved
    where(state: 'approved')
  end

  def self.new_from_payment(payment)
    self.new(payment_id: payment.id, 
             state: payment.state, 
             amount: payment.transactions.map{|t|t.amount.total.to_f}.sum,
             currency: 'usd',
             payment_method: 'paypal'
             )
  end
end