Mun::DelegationFieldType.register_types do
  type 'Name' do
    human_name 'Delegation Name'

    form_partial 'delegation_field_types/name'

    admin_render false
  end

  type 'String' do
    human_name 'Text'

    admin_render do |delegation_field_value, delegation|
      delegation_field_value
    end
  end

  type 'Integer' do
    human_name 'Integer'
    input_type 'Integer'

    admin_render do |delegation_field_value, delegation|
      delegation_field_value
    end
  end

  type 'Select' do
    human_name 'Multiple Choice'

    form_partial 'delegation_field_types/select'

    admin_render do |delegation_field_value, delegation|
      delegation_field_value
    end
  end

  type 'DelegationSize' do
    human_name 'Delegation Size'

    form_partial 'delegation_field_types/delegation_size'

    admin_render do |delegation_field_value, delegation|
      delegation.delegation_size
    end
  end

  type 'Address' do
    human_name 'Address (inc. city, state, etc)'

    form_partial 'delegation_field_types/address'

    admin_render do |delegation_field_value, delegation|
      delegation.address.andand.to_html
    end
  end

  type 'Advisors' do
    human_name 'Advisor Info (Names & Emails)'

    form_partial 'delegation_field_types/advisors'

    admin_render do |delegation_field_value, delegation|
      delegation.advisors.map{|a| "#{a.first_name} #{a.last_name}: #{a.email}"}.join('<br>').html_safe
    end
  end

  type 'CommitteeTypeSelection' do
    human_name 'Breakdown of Committees'

    form_partial 'delegation_field_types/committee_type_selections'

    admin_render do |delegation_field_value, delegation|
      delegation.committee_type_selections.map do |cts|
        "#{cts.committee_type.name}: #{cts.delegate_count}"
      end.join("<br>").html_safe
    end
  end

  type 'Preferences' do
    human_name 'Country Preferences'

    form_partial 'delegation_field_types/preferences'

    admin_render do |delegation_field_value, delegation|
      delegation.preferences.map{|p| "#{p.rank.andand + 1}: #{p.country.andand.name || 'None'}"}.join('<br>').html_safe
    end
  end

  type 'Title' do
    human_name 'Section Subtitle'

    form_partial 'delegation_field_types/subtitle'

    admin_render false
  end
end