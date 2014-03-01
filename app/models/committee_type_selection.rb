class CommitteeTypeSelection < ActiveRecord::Base
  belongs_to :delegation
  belongs_to :committee_type

  after_initialize :init

  def init
    self.delegate_count ||= 0
  end
end
