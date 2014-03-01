class Advisor < User
  before_validation :make_default_pass

  def make_default_pass
    if self.password.nil?
      self.password = 'blahblah'
    end
  end
end