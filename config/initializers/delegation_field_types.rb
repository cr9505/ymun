Mun::DelegationFieldType.register_types do
  type 'Name' do
    human_name 'Delegation Name'

    validate do |delegation_field_value_string, delegation|
      if delegation.name.blank?
          delegation.errors[:name] << 'Delegation name cannot be blank.'
      end
    end

    form_render 'delegation_field_types/name'

    admin_render do |delegation_field_value_string, delegation|
      delegation.name
    end
  end

  type 'String' do
    human_name 'Text'
  end

  type 'Integer' do
    human_name 'Integer'
    input_type 'Integer'
  end

  type 'Select' do
    human_name 'Multiple Choice'
  end

  type 'DelegationSize' do
    human_name 'Delegation Size'

    form_render 'delegation_field_types/delegation_size'

    validate do |delegation_field_value_string, delegation|
      if delegation.delegation_size.blank?
        delegation[:errors] << 'You must specify a number of delegates.'
      elsif (delegate_cap = Option.get('delegate_cap')).to_i > 0 &&
            delegation.delegation_size > delegate_cap
        delegation.errors[:delegation_size] << "You may bring no more than #{delegate_cap} delegates."
      else
        true
      end
    end

    admin_render do |delegation_field_value_string, delegation|
      delegation.delegation_size
    end
  end

  type 'Address' do
    human_name 'Address (inc. city, state, etc)'

    form_render 'delegation_field_types/address'

    validate do |delegation_field_value_string, delegation|
      if delegation.address.nil?
        delegation.errors[:address] << "You must provide an address."
      else
        delegation.address.errors[:street] << "You must specify a street address." if delegation.address.line1.blank?
        delegation.address.errors[:city] << "You must specify a city name." if delegation.address.city.blank?
        delegation.address.errors[:country] << "You must specify a country." if delegation.address.country.blank?
      end
    end

    admin_render do |delegation_field_value_string, delegation|
      delegation.delegation_size
    end
  end

  type 'Advisors' do
    human_name 'Advisor Info (Names & Emails)'

    form_render 'delegation_field_types/advisors'

    validate do |delegation_field_value_string, delegation|
      delegation.advisors.target.each do |advisor|
        if advisor.first_name.blank? || advisor.last_name.blank?
          delegation.errors[:advisors] << 'All advisors must have a first and a last name listed.'
        end
      end
    end

    admin_render do |delegation_field_value_string, delegation|
      delegation.advisors.map{|a| "#{a.first_name} #{a.last_name}: #{a.email}"}.join('<br>').html_safe
    end
  end

  type 'CommitteeTypeSelection' do
    human_name 'Breakdown of Committees'

    form_render 'delegation_field_types/committee_type_selections'

    validate do |delegation_field_value_string, delegation|
      if delegation.committee_type_selections.any?
        if delegation.delegation_size.present?
          size_by_committee_type = delegation.committee_type_selections.map(&:delegate_count).sum
          if size_by_committee_type != delegation.delegation_size
            delegation.errors[:'committee_type_selections'] << 'Number of delegates does not match total delegation size.'
          end
        end
        # TODO add ymge's weird half-size validation thing back here
      end
    end

    admin_render do |delegation_field_value_string, delegation|
      delegation.committee_type_selections.each do |cts|
        "#{cts.committee_type.name}: #{cts.delegate_count}"
      end.join("<br>").html_safe
    end
  end

  type 'Preferences' do
    human_name 'Committee Preferences'

    form_render 'delegation_field_types/preferences'

    validate do |delegation_field_value_string, delegation|
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
    end

    admin_render do |delegation_field_value_string, delegation|
      delegation.preferences.map{|p| "#{p.rank}: #{p.country.andand.name || 'None'}"}.join('<br>').html_safe
    end
  end

  type 'Title' do
    human_name 'Section Subtitle'

    form_render 'delegation_field_types/subtitle'

    admin_render false
  end
end
