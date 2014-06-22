class DelegationValidator < ActiveModel::Validator
  def validate(delegation)
    puts "STARTING VALIDATION"
    if delegation.step > 1 && delegation.name.blank?
      delegation.errors[:name] << 'Delegation name cannot be blank.'
    end
    if delegation.persisted? && delegation.advisors.count < 1
      delegation.errors[:'advisors'] << 'At least one advisor is required per delegation.'
    end
    if delegation.delegation_size.present?
      delegation_size = delegation.delegation_size
      if Option.get('delegate_cap').to_i > 0 && delegation_size > Option.get('delegate_cap')
        delegation.errors[:fields] << "You may bring no more than #{Option.get('delegate_cap')} delegates."
      end
      if Option.get('max_delegates_per_advisor').present? &&
         delegation.advisors.count * Option.get('max_delegates_per_advisor') < delegation_size
        delegation.warnings << "You must bring 1 advisor for every #{Option.get('max_delegates_per_advisor')} delegates."
      end
      if delegation.committee_type_selections.any?
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
    end
    delegation.fields.target.each do |field|
      if field.delegation_field.class_name == 'Integer' &&
         field.to_value < 0
        delegation.errors[:fields] << "#{field.delegation_field.name} must be non-negative."
      end
    end
    if delegation.payment_type.present? && !['paypal', 'check', 'bank'].include?(delegation.payment_type.to_s)
      delegation.errors[:payment_type] << 'Invalid Payment Type'
    end

    # ghetto uniqueness validation
    country_ids = []

    delegation.preferences.each do |pref|
      unless pref.country_id.nil?
        if country_ids.include? pref.country_id
          delegation.errors[:preferences] << 'Countries must be unique.'
          break
        end
        country_ids.push(pref.country_id)
      end
    end

    delegation.advisors.target.each do |advisor|
      if advisor.first_name.blank? || advisor.last_name.blank?
        delegation.errors[:advisors] << 'All advisors must have a first and a last name listed.'
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