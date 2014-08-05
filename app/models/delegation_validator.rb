class DelegationValidator < ActiveModel::Validator
  def validate(delegation)
    puts "STARTING VALIDATION"

    # TODO: make payment validation better

    delegation.payments.each do |p|
      if delegation.payment_currency.blank? ||
         delegation.payments.length <= 1
        delegation.payment_currency = p.currency.downcase
      elsif delegation.payment_currency.downcase != p.currency.downcase
        delegation.errors[:payments] << 'must all be in the same currency!'
        break
      end
    end

    puts "VALIDATION FINISHED"
    puts delegation.errors.inspect if delegation.errors.any?
  end
end
