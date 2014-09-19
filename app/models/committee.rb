class Committee < ActiveRecord::Base
  has_many :country_committees
  has_many :countries, through: :country_committees

  accepts_nested_attributes_for :country_committees, :allow_destroy => true
  
  has_many :characters

  def self.sync_with_drive
    sync_errors = []
    if google_doc = Option.get('committee_assignments_google_doc')
      google_doc_key = google_doc[/key=([^&])/, 1]
      if google_doc_key
        session = GoogleDrive.login(username, password)
        spreadsheet = session.spreadsheet_by_key(google_doc_key)
        parse_result = CommitteeParsers::YMGE.parse(spreadsheet.worksheets)
        parse_result['delegations'].each do |delegation_name, delegation_info|
          delegation = Delegation.find_by(name: delegation_name)
          if delegation.nil?
            sync_errors << "Delegation '#{delegation_name}' does not exist."
          else
            delegation_info['characters'].each do |committee_name, character_names|
              committee = Committee.find_or_create_by_name(committee_name)
              character_names.each do |character_name|
                character = Character.find_or_create_by_name(character_name)
              end
            end
          end
        end
      end
    end
  end

  # CommitteeParsers should return:
  # {
  #   'countries' => {
  #     CountryName => [CommitteeName]
  #   },
  #   'delegations' => {
  #     DelegationName => {
  #       'characters' => {
  #         CommitteeName => [SeatName]
  #       },
  #       'countries' => [CountryName]
  #     }
  #   }
  # }

  def self.find_or_create_by_name(name)
    committee = Committee.find_by(name: name)
    if committee.nil?
      committee = Committee.create(name: name)
    end
    committee
  end
end
