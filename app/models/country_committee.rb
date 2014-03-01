class CountryCommittee < ActiveRecord::Base
  # join model for countries and committees
  # for example, country = Albania and committee = World Health Organization
  belongs_to :country
  belongs_to :committee

  belongs_to :changer, class_name: 'Admin'

end