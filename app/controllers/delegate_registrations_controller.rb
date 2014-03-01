class DelegateRegistrationsController < Devise::RegistrationsController
  def devise_i18n_options(options)
    options[:scope] = 'devise.devise_controller'
    options[:resource_name] = 'user'
    options
  end
end