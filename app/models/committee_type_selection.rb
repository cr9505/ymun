class CommitteeTypeSelection < ActiveRecord::Base
  belongs_to :delegation
  belongs_to :committee_type

  after_initialize :init

  default_scope -> { order(:committee_type_id) }

  def init
    self.delegate_count ||= 0
  end
end
