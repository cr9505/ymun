class CharacterCommittee < ActiveRecord::Base
  belongs_to :character
  belongs_to :committee
  # after_destroy :ensure_seats
  # after_create :ensure_seats

  # def ensure_seats
  #   puts "FIRING"
  #   character.ensure_seats
  # end
end
