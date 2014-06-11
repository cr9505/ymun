class CommitteeTypeSelection < ActiveRecord::Base
  belongs_to :delegation
  belongs_to :committee_type

  after_initialize :init

  default_scope -> { order(:committee_type_id) }

  def init
    self.delegate_count ||= 0
  end

  def human_changes
    changes.inject({}) do |filtered_changes, (field, change)|
      if field == "committee_type_id"
        old_committee_type = CommitteeType.find_by_id(change[0])
        new_committee_type = CommitteeType.find_by_id(change[1])
        filtered_changes["committee_type"] = [old_committee_type.andand.name, new_committee_type.andand.name]
      end
      filtered_changes
    end
  end
end
