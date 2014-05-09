class MUNCountry < ActiveRecord::Base
  # class must be named MUNCountry because of country_select's Country class. Annoying
  self.table_name = 'countries'
  has_many :country_committees
  has_many :committees, through: :country_committees

  accepts_nested_attributes_for :committees

  def self.options_for_select
    self.all.map do |c|
      [c.name, c.id]
    end
  end
end
