class Seat < ActiveRecord::Base

  belongs_to :delegation
  belongs_to :delegate

  belongs_to :character
  belongs_to :country_committee
  delegate :country, to: :country_committee

  validates_uniqueness_of :delegate_id, allow_nil: true
  validates_uniqueness_of :country_committee_id, allow_nil: true

  def as_json(options = {})
    super(options.merge(methods: [:name, :committees]))
  end

  def name
    if character
      character.name
    elsif country
      country.name
    end
  end

  def committees
    if character
      character.committees
    elsif country_committee
      [country_committee.committee]
    else
      []
    end
  end

  # "assigns" delegation to either a character or a country, properly adjusting
  # the number of relevant seats to match character.seat_count
  def self.find_or_create_for(delegation, character)
    seats = Seat.where(delegation_id: delegation.id, character_id: character.id).to_a

    # remove seats if there are too many
    while seats.length > character.seat_count
      unassigned_seat = seats.find_index { |seat| seat.delegate.nil? }
      if unassigned_seat.nil?
        # drop any old seat -- delegate will have to be reassigned
        seats.shift(1)
      else
        seats.delete_at(unassigned_seat)
      end
    end

    # OR

    # add seats if there are too few
    while seats.length < character.seat_count
      seats << Seat.create(delegation_id: delegation.id, character_id: character.id)
    end
    seats
  end
end
