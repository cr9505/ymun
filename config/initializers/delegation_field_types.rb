Mun::DelegationFieldType.register_types do
  type 'Name' do
    human_name 'Delegation Name'

    validate do |delegation_field_value_string, delegation|
      delegation.name.present?
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
  end

  type 'Select' do
    human_name 'Multiple Choice'
  end

  type 'DelegationSize' do
    human_name 'Delegation Size'
  end

  type 'Address' do
    human_name 'Address (inc. city, state, etc)'
  end

  type 'Advisors' do
    human_name 'Advisor Info (Names & Emails)'
  end

  type 'CommitteeTypeSelection' do
    human_name 'Breakdown of Committees'
  end

  type 'Preferences' do
    human_name 'Committee Preferences'
  end

  type 'Title' do
    human_name 'Section Subtitle'
  end

end