class Committee < ActiveRecord::Base
  has_many :country_committees
  has_many :countries, through: :country_committees, class_name: 'MUNCountry'

  accepts_nested_attributes_for :country_committees, :allow_destroy => true
  
  has_many :characters

  def self.sync_with_drive(google_doc, username, password, committee_parser)
    google_doc_key = google_doc[/key=([^&]+)/, 1]
    google_doc_key = google_doc[/d\/([^\/]+)(\/edit)?/, 1] unless google_doc_key
    if username && password
      if google_doc_key
        session = GoogleDrive.login(username, password)
        spreadsheet = session.spreadsheet_by_key(google_doc_key)
        parse_result = committee_parser.parse(spreadsheet.worksheets)
        sync_errors = Committee.handle_committee_parser(parse_result)
        return sync_errors
      end
    end
    sync_errors = ['Could not access committee assignments spreadsheet. ' +
                   'You must specify a committee document URL, as well as ' +
                   'a Google account username and password that has access ' +
                   'to that document.']
    sync_errors
  end

  # CommitteeParsers should return:
  # {
  #   DelegationID => [
  #     {
  #       'name' => SeatName (e.g. "Barack Obama" or "USA (DISEC)")
  #       'seats' => SeatCount (e.g. 1)
  #       'committees' => [CommitteeName] (Usually just one)
  #     }
  #   ]
  # }
  def self.handle_committee_parser(parse_result)
    sync_errors = []

    parse_result.each do |delegation_id, characters|
      delegation = Delegation.find_by(id: delegation_id)
      if delegation.nil?
        sync_errors << "Delegation with ID=#{delegation_id} does not exist."
      else
        delegation.seats = characters.map do |character_info|
          character = Character.find_or_create_by_name(character_info['name'])
          character.seat_count = character_info['seat_count']
          character.delegation_id = delegation.id
          character.committees = character_info['committees'].map do |committee_name|
            Committee.find_or_create_by_name(committee_name)
          end
          character.save
          Seat.find_or_create_for(delegation, character)
        end.flatten
      end
    end

    # return sync_errors if there are any
    if sync_errors.any? then sync_errors else nil end
  end

  def self.find_or_create_by_name(name)
    committee = Committee.find_by("LOWER(name) = LOWER(?)", name)
    if committee.nil?
      committee = Committee.create(name: name)
    end
    committee
  end
end
