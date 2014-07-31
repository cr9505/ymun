require 'spec_helper'

describe Mun::DelegationFieldType do
  let :delegation do
    d = create(:delegation)
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

  context 'when type is Select' do
    let(:field) { fields['Select'] }

    it 'should be valid only when value is among the options' do
      field.options = 'one,two,three'
      field.save

      field_value = delegation.get_field_or_build(field)
      field_value.value = 'one'
      field.delegation_field_type.validate(field_value, delegation)
      expect(delegation.errors[:fields]).not_to be_present

      field_value.value = 'four'
      field.delegation_field_type.validate(field_value, delegation)
      expect(delegation.errors[:fields]).to be_present
    end

    it 'should allow any value if "other" is an option' do 
      field.options = 'one,two,three,other'
      field.save

      field_value = delegation.get_field_or_build(field)
      field_value.value = 'another'
      field.delegation_field_type.validate(field_value, delegation)
      expect(delegation.errors[:fields]).not_to be_present
    end
  end

  context 'when type is DelegationSize' do
    let(:field) { fields['DelegationSize'] }

    before do
      Option.stub('delegate_cap', 20)
    end

    it 'should not be valid when delegation_size is blank' do
      field_value = delegation.get_field_or_build(field)
      delegation.delegation_size = nil
      field.delegation_field_type.validate(field_value, delegation)
      expect(delegation.errors[:delegation_size]).to be_present
    end

    it 'should not be valid when delegation_size is over the maximum' do
      field_value = delegation.get_field_or_build(field)
      delegation.delegation_size = 24
      field.delegation_field_type.validate(field_value, delegation)
      expect(delegation.errors[:delegation_size]).to be_present
    end

    it 'should be valid when delegation_size is under the maximum' do
      field_value = delegation.get_field_or_build(field)
      delegation.delegation_size = 17
      field.delegation_field_type.validate(field_value, delegation)
      expect(delegation.errors[:delegation_size]).not_to be_present
    end
  end

  context 'when type is Advisors' do
    let(:field) { fields['Advisors'] }
      
    before do
      2.times do
        delegation.advisors << build(:advisor)
      end
    end

    it 'should not be valid when an advisor has a blank name or email' do
      field_value = delegation.get_field_or_build(field)

      delegation.advisors.first.first_name = ''
      field.delegation_field_type.validate(field_value, delegation)
      expect(delegation.errors[:advisors]).to be_present

      delegation.advisors.first.first_name = 'Present'
      delegation.advisors.first.last_name = ''
      field.delegation_field_type.validate(field_value, delegation)
      expect(delegation.errors[:advisors]).to be_present

      delegation.advisors.first.last_name = 'Present'
      delegation.advisors.first.email = ''
      field.delegation_field_type.validate(field_value, delegation)
      expect(delegation.errors[:advisors]).to be_present
    end

    it 'should be valid when all advisors have both a name and an email' do
      field_value = delegation.get_field_or_build(field)

      field.delegation_field_type.validate(field_value, delegation)
      expect(delegation.errors[:advisors]).not_to be_present
    end
  end

  context 'when type is CommitteeTypeSelection' do
    let(:field) { fields['CommitteeTypeSelection'] }
    let(:committee_types) do
      3.times.map do |i|
        build(:committee_type)
      end
    end

    before do
      committee_types.each do |ct|
        delegation.committee_type_selections << build(:committee_type_selection, committee_type_id: ct.id)
      end
    end

    it 'should not be valid when committee type selection counts do not add up to delegation_size' do
      delegation.delegation_size = 24

      delegation.committee_type_selections[0].delegate_count = 8
      delegation.committee_type_selections[1].delegate_count = 8
      delegation.committee_type_selections[2].delegate_count = 7

      field_value = delegation.get_field_or_build(field)
      field.delegation_field_type.validate(field_value, delegation)
      expect(delegation.errors[:committee_type_selections]).to be_present
    end

    it 'should not be valid when committee type selection counts are equal to delegation_size' do
      delegation.delegation_size = 24

      delegation.committee_type_selections[0].delegate_count = 8
      delegation.committee_type_selections[1].delegate_count = 8
      delegation.committee_type_selections[2].delegate_count = 8

      field_value = delegation.get_field_or_build(field)
      field.delegation_field_type.validate(field_value, delegation)
      expect(delegation.errors[:committee_type_selections]).not_to be_present
    end
  end

  context 'when type is Preferences' do
    let(:field) { fields['Preferences'] }

    before do
      3.times do |i|
        delegation.preferences << build(:preference, country_id: i)
      end
    end

    it 'should not be valid when preferences are not unique' do

      delegation.preferences[0].country_id = delegation.preferences[1].country_id

      field_value = delegation.get_field_or_build(field)
      field.delegation_field_type.validate(field_value, delegation)
      expect(delegation.errors[:preferences]).to be_present
    end

    it 'should not be valid when committee type selection counts are equal to delegation_size' do
      field_value = delegation.get_field_or_build(field)
      field.delegation_field_type.validate(field_value, delegation)
      expect(delegation.errors[:preferences]).not_to be_present
    end
  end
end