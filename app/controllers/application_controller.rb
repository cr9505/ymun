class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def authenticate_admin_user!
    authenticate_user! 
    unless current_user.admin?
      flash[:alert] = "This area is restricted to administrators only."
      redirect_to root_path 
    end
  end
   
  def current_admin_user
    return nil if user_signed_in? && !current_user.admin?
    current_user
  end

  def after_sign_in_path_for(user)
    case user.type
      when 'Advisor'
        if user.delegation.andand.registration_finished?
          delegation_path
        else
          edit_delegation_path
        end
      when 'Delegate'
        edit_registration_path(:delegate)
      when 'AdminUser'
        admin_root_path
    end
  end

  def new_admin_user_session_path
    new_user_session_path
  end

  def destroy_admin_user_session_path
    destroy_user_session_path
  end

end
