class DelegationMailer < ActionMailer::Base
  default from: Option.get('from_email')
# layout :email

  def create_notification(delegation, changer)
    @delegation = delegation
    @current_user = changer || @delegation.creator
    mail(from: Option.get('from_email'), to: Option.get('notification_emails'), subject: "#{Option.get('site_title')} Notifier: Delegation (ID=#{@delegation.id})")
  end

  def update_notification(delegation, changer)
    @delegation = delegation
    @current_user = changer || @delegation.creator
    mail(from: Option.get('from_email'), to: Option.get('notification_emails'), subject: "#{Option.get('site_title')} Notifier: Delegation (ID=#{@delegation.id})")
  end
end
