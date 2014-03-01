class Delegation < ActiveRecord::Base
  has_many :users
  has_many :delegates
  has_many :advisors

  has_one :address, as: :addressable, dependent: :destroy

  has_many :committees
  has_many :countries

  has_many :preferences, -> { order 'rank' }

  accepts_nested_attributes_for :preferences

  accepts_nested_attributes_for :address
  accepts_nested_attributes_for :advisors, reject_if: :all_blank

  has_many :fields, class_name: 'DelegationFieldValue', dependent: :destroy
  accepts_nested_attributes_for :fields, allow_destroy: true

  has_many :committee_type_selections, dependent: :destroy
  accepts_nested_attributes_for :committee_type_selections, allow_destroy: true

  after_initialize :init_defaults

  validates_with DelegationValidator

  def init_defaults
    self.step ||= 1
  end

  def pad_preferences
    num_preferences = Option.get('num_preferences')
    i = 0
    while preferences.length < num_preferences
      preferences << Preference.new(rank: i)
      i += 1
    end
  end

  # returns the value (integer, string, or array) associated with the field or slug FIELD
  # TODO: arrays
  def get_field_value(field)
    field_values = get_fields(field)
    return nil if field_values.blank?
    if field_values.first.delegation_field.multiple
      field_values.map(&:to_value)
    else
      field_values.first.to_value
    end
  end

  def all_fields(page = nil)
    if page
      delegation_fields = DelegationField.with_page(page).active
    else
      delegation_fields = DelegationField.active
    end
    delegation_fields.map do |field|
      get_fields(field).to_a
    end.flatten
  end

  # returns the DelegationFieldValues associated with the field or slug FIELD
  def get_fields(field)
    unless field.is_a? DelegationField
      field_slug = field.to_s
      field = DelegationField.where(slug: field_slug).first
      return nil if field.nil?
    end
    field_values = self.fields.where(delegation_field_id: field.id).includes(:delegation_field)
    if field_values.empty?
      field_values = [self.fields.build(delegation_field_id: field.id)]
    end
    field_values
  end

  def advance_step!
    self.step = self.step + 1
    save
  end

  def registration_finished?
    self.step > (DelegationPage.maximum(:step) || 0)
  end

  def payment_items
    price = Option.get('delegation_price')
    items_with_prices = price.split('*').map(&:trim)

    items = []
    items << { name: "Delegate Fee (x#{delegation_size})", price: self.delegation_size * Option.get('delegate_fee')}
  end

  def payment_balance
    payment_items.collect do |item|
      item[:price]
    end.reduce(:+)
  end

  def selection_for_committee_type(ct)
    self.committee_type_selections.where(committee_type_id: ct.id).first or 
    self.committee_type_selections.new(committee_type_id: ct.id)
  end

  def all_committee_type_selections
    CommitteeType.all.map do |ct|
      selection_for_committee_type(ct)
    end
  end

  def warnings
    @warnings ||= []
  end

  def warnings=(val)
    @warnings = val
  end

  def delegation_size
    get_field_value(:delegation_size)
  end

  # def respond_to?(sym, include_private = false)
  #   !!DelegationField.where(slug: sym.to_s).first
  # end

  # def method_missing(sym, *args, &block)
  #   # check whether sym is a valid field
  #   field = get_field_value(sym)
  #   if field
  #     field
  #   else
  #     super(sym, *args, &block)
  #   end
  # end
end
