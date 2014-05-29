class Preference < ActiveRecord::Base
  belongs_to :country, class_name: 'MUNCountry'
  belongs_to :delegation

  def human_identifier
    if country
      country.name
    else
      "Rank #{rank + 1}"
    end
  end

  # validates_uniqueness_of :country_id, scope: :delegation_id, :allow_nil => true, message: 'Countries must be unique.'
  # ^ that validation is now done in DelegationValidator
end
