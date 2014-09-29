class Delegation < ActiveRecord::Base

  has_many :users
  has_many :delegates
  has_many :advisors, -> { order 'created_at' }

  has_many :payments

  has_one :address, as: :addressable, dependent: :destroy

  has_many :committees
  has_many :countries, class_name: 'MUNCountry'
  has_many :characters

  has_many :preferences, -> { order 'rank' }

  accepts_nested_attributes_for :preferences, allow_destroy: true

  accepts_nested_attributes_for :address
  accepts_nested_attributes_for :advisors, :allow_destroy => true,
                                reject_if: ->(advisor) { advisor[:email].blank? &&
                                                         advisor[:first_name].blank? &&
                                                         advisor[:last_name].blank? }

  has_many :fields, class_name: 'DelegationFieldValue', dependent: :destroy
  accepts_nested_attributes_for :fields, allow_destroy: true, reject_if: ->(dfv) { dfv[:value].blank? }

  has_many :committee_type_selections, dependent: :destroy
  accepts_nested_attributes_for :committee_type_selections, allow_destroy: true

  after_initialize :init_defaults

  before_create :check_for_late_registration

  before_save :send_update_notification
  after_save :send_create_notification

  before_save :check_for_late_delegates

  attr_accessor :changer, :send_notification, :saving_step, :saving_page

  validates_presence_of :name, :if => :should_validate_name?
  validates_presence_of :delegation_size, :if => :should_validate_delegation_size?
  validate :delegation_size, :if => :should_validate_delegation_size? do |delegation|
    if Option.get('delegate_cap') && delegation.delegation_size.to_i > Option.get('delegate_cap')
      delegation.errors[:delegation_size] = "must be less than or equal to #{Option.get('delegate_cap')}"
    end
  end
  validates_numericality_of :delegation_size, greater_than_or_equal_to: 0, :if => :should_validate_delegation_size?

  validate :delegation_size, :if => :should_validate_delegation_size? do |delegation|
    if delegation.committee_type_selections
      delegate_sum = delegation.committee_type_selections.reduce(0) do |sum, cts|
        sum += cts.delegate_count || 0
      end
      if delegate_sum != delegation.delegation_size
        delegation.errors[:delegation_size] << 'does not match committee type selection numbers'
      end
    end
  end

  validate :payment_type do |delegation|
    if delegation.payment_type == 'paypal'
      if delegation.payment_currency.present? && delegation.payment_currency.downcase != 'usd'
        delegation.errors[:payment_type] = 'can only be paypal if you are paying with USD'
      end
    end
  end

  validates_with DelegationValidator

  def init_defaults
    self.step ||= 1
    # self.address ||= Address.new
    self.late_delegate_count ||= 0
    self.late_advisor_count ||= 0
    self.is_late_delegation ||= false
  end

  def self.with_name
    where.not(name: '')
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
    field_values = get_fields(field)
    if field_values.empty?
      field_values = [self.fields.build(delegation_field_id: field.id)]
    end
    field_values
  end

  def get_field_or_build(field)
    get_fields_or_build(field).andand.first
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
      delegation_price.gsub! /<br( \/)?>/, "\n"
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
        val = send(property)
        if val
          if val.respond_to? :to_i
            val.to_i
          else
            1
          end
        else
          0
        end
      else
        0
      end
    end
  end

  def payment_items
    Delegation.payment_items.map do |item|
      count = payment_property(item[:property])
      if count > 0
        { name: item[:name], price: item[:price], count: count }
      end
    end.compact
  end

  def total_payment_owed(curr=nil)
    curr ||= payment_currency || 'usd'
    curr = curr.to_s.downcase.to_sym
    payment_items.collect do |item|
      p item
      item[:price][curr] * item[:count]
    end.sum
  end

  def total_payment_paid(curr=nil)
    approved_payments.collect(&:amount).sum
  end

  def payment_balance(curr=:usd)
    total_payment_owed(curr) - total_payment_paid(curr)
  end

  def paid_deposit?
    if payment_currency
      deposit = Option.get("deposit_#{payment_currency.downcase}") || Option.get('deposit_usd')
      total_payment_paid >= deposit
    else
      false
    end
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

  def advisor_count
    advisors.count
  end

  def one
    1
  end

  def total_tshirts
    DelegationField.where('slug LIKE ?', '%_tshirts').map{|df| get_field_value(df)}.compact.sum
  end

  def is_small_delegation
    if (self.delegation_size || 0) <= 5
      1
    else
      0
    end
  end

  def is_big_delegation
    1 - self.is_small_delegation
  end

  def paying_with_paypal
    if self.payment_type == 'paypal'
      1
    else
      0
    end
  end

  def early_delegate_count
    (delegation_size || 0) - (late_delegate_count || 0)
  end

  def early_advisor_count
    (advisor_count || 0) - (late_advisor_count || 0)
  end

  def is_early_delegation
    if is_late_delegation then 0 else 1 end
  end

  def creator
    if self.advisors.any?
      self.advisors.first
    elsif delegates.any?
      self.delegate.first
    else
      nil
    end
  end

  def send_update_notification
    if send_notification && !self.new_record?
      mail = DelegationMailer.update_notification(self, @changer)
      mail.deliver
    end
  end

  def send_create_notification
    if send_notification && self.id_changed?
      mail = DelegationMailer.create_notification(self, @changer)
      mail.deliver
    end
  end

  def nested_changes
    reflections = Delegation.reflect_on_all_associations
    changes = {}
    reflections.each do |reflection|
      if reflection.collection?
        objs = self.send(reflection.name).target
        reflection_changes = objs.map do |obj|
          if obj.marked_for_destruction?
            { identifier: obj.human_identifier, state: 'deleted', changes: nil }
          elsif obj.id.nil?
            { identifier: obj.human_identifier, state: 'created', changes: obj.human_changes }
          elsif obj.changed?
            { identifier: obj.human_identifier, state: 'changed', changes: obj.human_changes }
          else
            nil
          end
        end.compact
        changes[reflection.name] = reflection_changes unless reflection_changes.empty?
      else
        if self.association(reflection.name).loaded?
          obj = self.send(reflection.name)
          if obj
            reflection_change = 
              if obj.marked_for_destruction?
                { identifier: obj.human_identifier, state: 'deleted', changes: nil }
              elsif obj.id.nil?
                { identifier: obj.human_identifier, state: 'created', changes: obj.human_changes }
              elsif obj.changed?
                { identifier: obj.human_identifier, state: 'changed', changes: obj.human_changes }
              else
                nil
              end
            changes[reflection.name] = [reflection_change] unless reflection_change.nil?
          end
        end
      end
    end
    changes
  end

  def check_for_late_registration
    late_registration_date = Option.get('late_registration_date')
    if late_registration_date && Date.today > late_registration_date
      self.is_late_delegation = true
      self.late_advisor_count = self.advisors.count
    else
      self.is_late_delegation = false
    end
    true
  end

  def check_for_late_delegates
    puts "CHANGES: #{changes}"
    if changes['delegation_size']
      late_registration_date = Option.get('late_registration_date')
      if late_registration_date && Date.today > late_registration_date
        before, after = changes['delegation_size'].map(&:to_i)
        self.late_delegate_count += (after - before)
        if self.late_delegate_count < 0
          self.late_delegate_count = 0
        end
      end
    end
    true
  end

  def should_validate_name?
    return false unless saving_step
    @saving_page ||= Page.find_by(step: @saving_step)
    @saving_page.delegation_fields.where(class_name: 'Name').any?
  end

  def should_validate_delegation_size?
    return false unless saving_step
    @saving_page ||= Page.find_by(step: @saving_step)
    @saving_page.delegation_fields.where(class_name: 'DelegationSize').any?
  end

  def saving_advisors?
    return false unless @saving_step
    @saving_page ||= Page.find_by(step: @saving_step)
    @saving_page.delegation_fields.where(class_name: 'Advisors').any?
  end

  def save(*args)
    super
  rescue ActiveRecord::RecordNotUnique => error
    if error.message =~ /index_preferences/
      errors[:preferences] << 'must be unique'
      preferences.target.each { |p| p.id = nil }
    else
      errors[:base] << error.message
    end
    false
  end

  # def respond_to?(sym, include_private = false)
  #   !!DelegationField.where(slug: sym.to_s).first
  # end
end
