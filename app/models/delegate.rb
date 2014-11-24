class Delegate < User
  before_validation :make_default_pass

  before_save :skip_email_confirmation

  default_scope -> { order(:created_at) }

  has_one :seat

  def self.with_seat
    includes(:seat).group('users.id, seats.id').having('COUNT(seats.id) > 0').references(:seat)
  end

  def human_identifier
    "#{first_name} #{last_name} (#{email})"
  end

  def skip_email_confirmation
    skip_confirmation!
    skip_reconfirmation!
  end

  def make_default_pass
    if self.encrypted_password.blank?
      self.password = Devise.friendly_token
    end
  end
  
end
