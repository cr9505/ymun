class DelegationField < ActiveRecord::Base
  belongs_to :delegation_page

  before_save :add_slug

  default_scope -> { order('delegation_page_id, position') }

  after_initialize :init

  def init
    self.multiple = false
    self.active = true
  end

  def add_slug
    self.slug ||= name.downcase.gsub(/[^\s\w_]/, '').strip.gsub(/[\s]+/, '_')
  end

  def self.active
    where(active: true)
  end

  def self.with_page(page)
    page.delegation_fields
  end

  def parent
    self.delegation_page
  end

  def children
    DelegationField.none
  end
end