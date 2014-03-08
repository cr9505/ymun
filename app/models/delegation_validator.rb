class DelegationValidator < ActiveModel::Validator
  def validate(delegation)
    puts "STARTING VALIDATION"
    if delegation.persisted? && delegation.advisors.count < 1
      delegation.errors[:'advisors'] << 'At least one advisor is required per delegation.'
    end
    if delegation.delegation_size.present?
      delegation_size = delegation.delegation_size
      if Option.get('max_delegates_per_advisor').present? &&
         delegation.advisors.count * Option.get('max_delegates_per_advisor') < delegation_size
        delegation.errors[:advisors] << "You must bring 1 advisor for every #{Option.get('max_delegates_per_advisor')} delegates."
      end
      size_by_committee_type = delegation.committee_type_selections.map(&:delegate_count).sum
      if size_by_committee_type != delegation_size
        delegation.errors[:'committee_type_selections'] << 'Number of delegates does not match total delegation size.'
      end
      # TODO clean this up
      council_selection = delegation.committee_type_selections.find{|cts| cts.committee_type_id == 1 }
      if council_selection && council_selection.delegate_count > 0.5 * delegation_size
        delegation.errors[:'committee_type_selections'] << 'No more than half of your delegates may be National Cabinets/Councils of Ministers.'
      end
    end
    delegation.fields.target.each do |field|
      if field.delegation_field.class_name == 'Integer' &&
         field.to_value < 0
        delegation.errors[:fields] << "#{field.delegation_field.name} must be non-negative."
      end
    end
    unless delegation.payment_type.blank? || ['paypal', 'check', 'bank'].include?(delegation.payment_type)
      delegation.errors[:payment_type] << 'Invalid Payment Type'
    end
    if delegation.payment_currency != :usd && @payment_type == :paypal
      delegation.errors[:payment_type] << 'You can only pay with paypal if you use USD.'
    end
    puts "VALIDATION FINISHED"
    puts delegation.errors.inspect if delegation.errors.any?
  end
end