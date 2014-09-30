class Seat < ActiveRecord::Base

  belongs_to :delegation
  belongs_to :delegate

  belongs_to :character
  belongs_to :country_committee

  # "assigns" delegation to either a character or a country
  # if delegation is already assigned, does nothing
  # returns a list of relevant seats
  def self.find_or_create_for(delegation, character_or_country)
    case character_or_country
    when Character
      character = character_or_country
      seat = Seat.find_by(delegation_id: delegation.id, character_id: character.id)
      if seat.nil?
        seat = Seat.create(delegation_id: delegation.id, character_id: character.id)
      end
      [seat]
    when MUNCountry
      country = character_or_country
      #TODO
    end
  end
end
