class AdvisorRegistrationsController < Devise::RegistrationsController
  def devise_i18n_options(options)
    options[:scope] = 'devise.registrations'
    options[:resource_name] = ''
    options
  end
end