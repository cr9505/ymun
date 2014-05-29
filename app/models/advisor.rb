class Advisor < User
  before_validation :make_default_pass

  def human_identifier
    "#{first_name} #{last_name} (#{email})"
  end

  def make_default_pass
    if self.encrypted_password.nil?
      puts "FUCKYOUUUUUUUUUU"
      self.password = 'blahblah'
    end
  end
end