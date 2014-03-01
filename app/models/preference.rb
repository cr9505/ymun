class Preference < ActiveRecord::Base
  belongs_to :country
  belongs_to :delegation

  validates_uniqueness_of :rank, scope: :delegation_id
  validates_uniqueness_of :country_id, scope: :delegation_id, :allow_nil => true
end
