class CharacterCommittee < ActiveRecord::Base
  belongs_to :character
  belongs_to :committee
end
