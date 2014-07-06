class DelegationValidator < ActiveModel::Validator
  def validate(delegation)
    puts "STARTING VALIDATION"
    if delegation.saving_step
      page = DelegationPage.find_by(step: delegation.saving_step)
      delegation.all_fields(page).each do |delegation_field_value|
        type = delegation_field_value.delegation_field_type
        type.validate(delegation_field_value, delegation)
      end
    end

    # TODO: make payment validation better

    delegation.payments.each do |p|
      if delegation.payment_currency.blank? ||
         delegation.payments.length <= 1
        delegation.payment_currency = p.currency.downcase
      elsif delegation.payment_currency.downcase != p.currency.downcase
        delegation.errors[:payments] << 'All payments must be in the same currency!'
        p.errors[:currency] << 'All payments must be in the same currency!'
      end
    end
    if delegation.payment_currency.andand.downcase != 'usd' && delegation.payment_type == 'paypal'
      delegation.errors[:payment_type] << 'You can only pay with paypal if you use USD.'
    end
    puts "VALIDATION FINISHED"
    puts delegation.errors.inspect if delegation.errors.any?
  end
end