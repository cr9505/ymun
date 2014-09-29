class Committee < ActiveRecord::Base
  has_many :country_committees
  has_many :countries, through: :country_committees, class_name: 'MUNCountry'

  accepts_nested_attributes_for :country_committees, :allow_destroy => true
  
  has_many :characters

  def self.sync_with_drive
    if google_doc = Option.get('committee_assignments_google_doc')
      google_doc_key = google_doc[/key=([^&])/, 1]
      if google_doc_key
        session = GoogleDrive.login(username, password)
        spreadsheet = session.spreadsheet_by_key(google_doc_key)
        parse_result = CommitteeParsers::YMGE.parse(spreadsheet.worksheets)
        sync_errors = Committee.handle_committee_parser(parse_result)
      end
    end
  end

  # CommitteeParsers should return:
  # {
  #   'countries' => {
  #     CountryName => [CommitteeName]
  #   },
  #   'delegations' => {
  #     DelegationID => {
  #       'characters' => [
  #         {
  #           'name' => SeatName
  #           'committees' => [CommitteeName]
  #         }
  #       ]
  #         SeatName => [CommitteeName]
  #       },
  #       'countries' => [CountryName]
  #     }
  #   }
  # }
  def self.handle_committee_parser(parse_result)
    sync_errors = []
    parse_result['countries'].andand.each do |country_name, committee_names|
      country = MUNCountry.find_or_create_by_name(country_name)
      committee_names.each do |committee_name|
        committee = Committee.find_or_create_by_name(committee_name)
        unless country.committees.exists?(id: committee.id)
          country.committees << committee
        end
      end
    end

    parse_result['delegations'].andand.each do |delegation_id, delegation_info|
      delegation = Delegation.find_by(id: delegation_id)
      if delegation.nil?
        sync_errors << "Delegation with ID=#{delegation_id} does not exist."
      else
        delegation_info['characters'].andand.each_with_index do |character_info, i|
          character = Character.find_or_create_by_seat_index(delegation, i)
          character.name = character_info['name']
          character_info['committees'].each do |committee_name|
            committee = Committee.find_or_create_by_name(committee_name)
            unless character.committees.exists?(id: committee.id)
              character.committees << committee
            end
          end
          character.save
        end
        delegation_info['countries'].andand.each do |country_name|
          country = MUNCountry.find_or_create_by_name(country_name)
          unless delegation.countries.exists?(id: country.id)
            delegation.countries << country
          end
        end
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
