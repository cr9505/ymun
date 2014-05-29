class DelegationFieldValue < ActiveRecord::Base
  belongs_to :delegation_field
  belongs_to :delegation

  def human_identifier
    label
  end

  def to_value
    puts delegation_field.class_name
    case delegation_field.class_name
    when 'Integer'
      value.to_i
    when 'String'
      value
    when 'Select'
      value
    end
  end

  def label
    delegation_field.name
  end

  def multiple
    delegation_field.multiple
  end

  def input_type
    case delegation_field.class_name
    when 'Integer'
      :integer
    when 'String'
      :string
    end
  end

  def required
    false
  end
end