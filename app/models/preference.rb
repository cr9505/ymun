class Preference < ActiveRecord::Base
  belongs_to :country, class_name: 'MUNCountry'
  belongs_to :delegation

  # validates_uniqueness_of :country_id, scope: :delegation_id, :allow_nil => true, message: 'Countries must be unique.'
  # ^ that validation is now done in DelegationValidator

  def human_identifier
    if country
      country.name
    else
      "Rank #{rank + 1}"
    end
  end

  def human_changes
    changes.inject({}) do |filtered_changes, (field, change)|
      if field == "country_id"
        old_country = MUNCountry.find_by_id(change[0])
        new_country = MUNCountry.find_by_id(change[1])
        filtered_changes["country"] = [old_country.andand.name, new_country.andand.name]
      end
      filtered_changes
    end
  end
end
