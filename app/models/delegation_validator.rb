class DelegationValidator < ActiveModel::Validator
  def validate(delegation)
    puts "STARTING VALIDATION"
    if delegation.advisors.count < 1
      delegation.errors[:'advisors'] << 'At least one advisor is required per delegation.'
    end
    if delegation.delegation_size.present?
      delegation_size = delegation.delegation_size
      if Option.get('max_delegates_per_advisor').present? &&
         delegation.advisors.count * Option.get('max_delegates_per_advisor') < delegation.delegation_size
        delegation.warnings << "You must bring 1 advisor for every #{Option.get('max_delegates_per_advisor')} delegates."
      end
      size_by_committee_type = delegation.committee_type_selections.map(&:delegate_count).sum
      if size_by_committee_type != delegation.delegation_size
        delegation.errors[:'committee_type_selections'] << 'Number of delegates does not match total delegation size.'
      end
      # TODO clean this up
      puts delegation.committee_type_selections.find{|cts| cts.committee_type_id == 1 }.delegate_count
      if delegation.committee_type_selections.find{|cts| cts.committee_type_id == 1 }.delegate_count > 0.5 * delegation_size
        delegation.errors[:'committee_type_selections'] << 'No more than half of your delegates may be National Cabinets/Councils of Ministers.'
      end
    end
    puts "VALIDATION FINISHED"
  end
end