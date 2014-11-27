class CharacterCommittee < ActiveRecord::Base
  belongs_to :character
  belongs_to :committee
  after_destroy :ensure_seats

  def ensure_seats
    character.ensure_seats
  end
end
