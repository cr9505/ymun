class Character < ActiveRecord::Base
  has_many :character_committees
  has_many :committees, through: :character_committees

  belongs_to :delegation
  def self.find_or_create_by_seat_index(delegation, seat_index)
    character = delegation.characters.find_by(seat_index: seat_index)
    if character.nil?
      character = Character.create(seat_index: seat_index, delegation_id: delegation.id)
    end
    character
  end
end
