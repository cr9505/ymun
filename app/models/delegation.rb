class Delegation < ActiveRecord::Base
  has_many :users
  has_many :delegates
  has_many :advisors

  has_many :payments

  has_one :address, as: :addressable, dependent: :destroy

  has_many :committees
  has_many :countries

  has_many :preferences, -> { order 'rank' }

  accepts_nested_attributes_for :preferences

  accepts_nested_attributes_for :address
  accepts_nested_attributes_for :advisors, reject_if: ->(advisor) { advisor[:email].blank? &&
                                                                    advisor[:first_name].blank? &&
                                                                    advisor[:last_name].blank? }

  has_many :fields, class_name: 'DelegationFieldValue', dependent: :destroy
  accepts_nested_attributes_for :fields, allow_destroy: true, reject_if: :all_blank

  has_many :committee_type_selections, dependent: :destroy
  accepts_nested_attributes_for :committee_type_selections, allow_destroy: true

  after_initialize :init_defaults

  validates_with DelegationValidator

  def init_defaults
    self.step ||= 1
    self.address ||= Address.new
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
      get_fields_or_build(field).to_a
    end.flatten
  end

  # returns the DelegationFieldValues associated with the field or slug FIELD
  def get_fields_or_build(field)
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

  def get_fields(field)
    unless field.is_a? DelegationField
      field_slug = field.to_s
      field = DelegationField.where(slug: field_slug).first
      return nil if field.nil?
    end
    self.fields.where(delegation_field_id: field.id).includes(:delegation_field)
  end

  def advance_step!
    self.step = self.step + 1
    save
  end

  def registration_finished?
    self.step > (DelegationPage.maximum(:step) || 0)
  end

  def self.reset_payment_items
    @@payment_items = nil
  end

  def self.payment_items
    @@payment_items ||= -> do
      delegation_price = Option.get('delegation_price')
      return [] if delegation_price.blank?
      items_with_names_and_prices = delegation_price.lines
      items = items_with_names_and_prices.map do |i|
        name, item_with_price = i.split(':')
        prices, property = item_with_price.split('*')
        price = prices.gsub(/[\(\)]/, '').split(/[,\|\/]+/).inject({}) do |p, price_with_curr|
          price = price_with_curr.gsub(/[^0-9]/,'').to_i
          curr = price_with_curr.gsub(/[^a-zA-Z]/,'').downcase.to_sym
          puts p.inspect
          p[curr] = price
          p
        end
        property = if property then property.strip.to_sym else :one end
        { name: name.strip, price: price, property: property }
      end
    end.call
  end

  def payment_property(property)
    fields = get_fields(property)
    if fields.present?
      fields.first.value.to_i
    else
      # must be a member method
      if self.respond_to? property
        send(property).to_i
      else
        0
      end
    end
  end

  def payment_items
    Delegation.payment_items.map do |item|
      { name: item[:name], price: item[:price], count: payment_property(item[:property]) }
    end
  end

  def total_payment_owed(curr=nil)
    curr ||= payment_currency || 'usd'
    payment_items.collect do |item|
      item[:price][curr] * item[:count]
    end.sum
  end

  def total_payment_paid(curr=nil)
    curr ||= payment_currency || 'usd'
    approved_payments.collect(&:amount).sum
  end

  def payment_balance(curr=:usd)
    total_payment_owed(curr) - total_payment_paid(curr)
  end

  def paid_deposit?
    deposit = Option.get("deposit_#{payment_currency.downcase}") || Option.get('deposit_usd')
    total_payment_paid >= deposit
  end

  def approved_payments
    self.payments.where(state: 'approved')
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
    field = DelegationField.where(slug: 'delegation_size').first
    return 0 unless field
    fields.target.find{|f| f.delegation_field_id == field.id}.andand.to_value || get_field_value(field)
  end

  def advisor_count
    advisors.count
  end

  def one
    1
  end

  def total_tshirts
    DelegationField.where('slug LIKE ?', '%_tshirts').map{|df| get_field_value(df)}.compact.sum
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
