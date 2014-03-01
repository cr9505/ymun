class DelegationFieldValue < ActiveRecord::Base
  belongs_to :delegation_field
  belongs_to :delegation

  def to_value
    case delegation_field.class_name
    when 'Integer'
      value.to_i
    when 'String'
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