class HomeController < ApplicationController
  def index
    unless user_signed_in?
      redirect_to new_session_path(:user) and return
    end
    if current_user.type == 'AdminUser'
      redirect_to admin_root_path
    end
  end
end
