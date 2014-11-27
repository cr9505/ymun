class MUNCountry < ActiveRecord::Base
  # class must be named MUNCountry because of country_select's Country class. Annoying
  self.table_name = 'countries'

  default_scope -> { order 'name' }
  has_many :country_committees, foreign_key: 'country_id'
  has_many :committees, through: :country_committees

  accepts_nested_attributes_for :committees

  belongs_to :delegation

  after_save :ensure_seats
  after_destroy :ensure_seats

  def self.options_for_select
    self.all.map do |c|
      [c.name, c.id]
    end
  end

  def self.find_or_create_by_name(name)
    country = MUNCountry.find_by("LOWER(name) = LOWER(?)", name)
    if country.nil?
      country = MUNCountry.create(name: name)
    end
    country
  end

  def ensure_seats
    if delegation && !delegation.ensuring
      delegation.ensure_seats
    end
  end
end
