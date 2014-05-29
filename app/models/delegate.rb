class Delegate < User

  def human_identifier
    "#{first_name} #{last_name} (#{email})"
  end
  
end