class DelegationFieldValue < ActiveRecord::Base
  belongs_to :delegation_field
  belongs_to :delegation

  validates_presence_of :value, :if => :required
  validates_numericality_of :value, greater_than_or_equal_to: 0, allow_blank: true, :if => :integer?
  validate :value, :if => :select? do |delegation_field_value|
    options = delegation_field_value.delegation_field.options.and.split(',')
    if options
      unless options.include?('other')
        unless options.include?(delegation_field_value.to_value)
          delegation_field_value.errors[:value] = "is not valid: #{delegation_field_value.to_value}"
        end
      end
    end
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

  def name
    delegation_field.name
  end

  def multiple
    delegation_field.multiple
  end
  
  def human_identifier
    name
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

  def human_changes
    changes.inject({}) do |filtered_changes, (field, change)|
      if field == "value"
        filtered_changes[field] = change
      end
      filtered_changes
    end
  end

  def delegation_field_type
    delegation_field.delegation_field_type
  end

  def integer?
    delegation_field.class_name == 'Integer'
  end

  def select?
    delegation_field.class_name == 'Select'
  end
end
