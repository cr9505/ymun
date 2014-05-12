class CustomDeviseMailer < Devise::Mailer
  default from: Option.get('from_email')
end