class HomeController < ApplicationController
  def index
    if user_signed_in?
      if current_user.type == 'AdminUser'
        redirect_to admin_root_path
      else
        redirect_to controller: :delegations, action: :edit
      end
    else
      redirect_to new_session_path(:user) and return
    end
  end
end
