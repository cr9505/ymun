class AdminUser < User
  def admin?
    true
  end
end