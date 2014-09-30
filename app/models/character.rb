class Character < ActiveRecord::Base
  has_many :character_committees
  has_many :committees, through: :character_committees

  has_one :seat

  belongs_to :delegation

  def self.find_or_create_by_name(name)
    character = Character.find_by("LOWER(name) = LOWER(?)", name)
    if character.nil?
      character = Character.create(name: name)
    end
    character
  end
end
