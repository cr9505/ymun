class DelegationPage < ActiveRecord::Base
  has_many :delegation_fields
  accepts_nested_attributes_for :delegation_fields, :allow_destroy => true

  after_initialize :init

  def init
    step ||= (DelegationPage.maximum(:step) || 0) + 1
  end

  def position
    self.step
  end

  def children
    self.delegation_fields
  end

  def parent
    nil
  end

  def step_index
    step - 1
  end

  def step_index=(i)
    self.step = i + 1
  end
end