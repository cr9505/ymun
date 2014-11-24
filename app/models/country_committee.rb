class CountryCommittee < ActiveRecord::Base
  # join model for countries and committees
  # for example, country = Albania and committee = World Health Organization
  belongs_to :country, class_name: 'MUNCountry'
  belongs_to :committee

  belongs_to :changer, class_name: 'Admin'

  has_one :seat

end
