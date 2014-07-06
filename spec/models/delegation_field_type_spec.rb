require 'spec_helper'

describe Mun::DelegationFieldType do
  let :delegation do
    d = build_stubbed(:delegation)
  end

  let :fields do
    fields_ary = [
      'Name',
      'String',
      'Integer',
      'Select',
      'Title',
      'Address',
      'DelegationSize',
      'Advisors',
      'CommitteeTypeSelection',
      'Preferences'
    ].collect do |field_type|
      [field_type, create(:delegation_field, class_name: field_type,
                          name: "Example #{field_type}")]
    end

    Hash[fields_ary]
  end

  context 'when type is Name' do
    let(:field) { fields['Name'] }

    it 'should be valid only when name is present' do
      delegation.name = 'Test Delegation'
      field.delegation_field_type.validate(delegation.get_field_or_build(field), delegation)
      expect(delegation.errors[:name]).not_to be_present

      delegation.name = ''
      field.delegation_field_type.validate(delegation.get_field_or_build(field), delegation)
      expect(delegation.errors[:name]).to be_present
    end
  end

  context 'when type is Integer' do
    let(:field) { fields['Integer'] }

    it 'should be valid only when value is nonnegative' do
      field_value = delegation.get_field_or_build(field)
      field_value.value = '8'
      field.delegation_field_type.validate(field_value, delegation)
      expect(delegation.errors[:fields]).not_to be_present

      field_value.value = ''
      field.delegation_field_type.validate(field_value, delegation)
      expect(delegation.errors[:fields]).not_to be_present

      field_value.value = '-8'
      field.delegation_field_type.validate(field_value, delegation)
      expect(delegation.errors[:fields]).to be_present
    end
  end

  context 'when type is Address' do
    let(:field) { fields['Address'] }

    it 'should be valid only when all required fields are present' do
      field.delegation_field_type.validate(delegation.get_field_or_build(field), delegation)
      expect(delegation.errors[:name]).not_to be_present

      delegation.address.line1 = ''
      field.delegation_field_type.validate(delegation.get_field_or_build(field), delegation)
      expect(delegation.errors[:address]).to be_present
    end
  end
end