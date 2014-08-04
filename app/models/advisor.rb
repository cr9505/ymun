class Advisor < User
  before_validation :make_default_pass

  after_create :increment_late_advisors
  after_destroy :decrement_late_advisors

  validates_presence_of :first_name, :last_name, :if => :delegation_exists?

  def human_identifier
    "#{first_name} #{last_name} (#{email})"
  end

  def make_default_pass
    if self.encrypted_password.nil?
      self.password = 'blahblah'
    end
  end

  def increment_late_advisors
    late_registration_date = Option.get('late_registration_date')
    if late_registration_date && Date.today > late_registration_date
      if self.delegation
        self.delegation.late_advisor_count ||= 0
        self.delegation.late_advisor_count += 1
        self.delegation.save
      end
    end
    true
  end

  def decrement_late_advisors
    if self.delegation.andand.late_advisor_count
      if self.delegation.late_advisor_count > 0
        self.delegation.late_advisor_count -= 1
        self.delegation.save
      end
    end
    true
  end

  def delegation_exists?
    !!delegation
  end
end