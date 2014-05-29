class DelegationMailer < ActionMailer::Base
  default from: Option.get('from_email')
# layout :email

  def create_notification(delegation)
    @delegation = delegation
    mail(from: Option.get('from_email'), to: Option.get('main_email'), subject: "#{Option.get('site_title')} Notifier: Delegation (ID=#{@delegation.id})")
  end

  def update_notification(delegation)
    @delegation = delegation
    @changes = @delegation.all_changes
    return nil
    mail(from: Option.get('from_email'), to: Option.get('main_email'), subject: "#{Option.get('site_title')} Notifier: Delegation (ID=#{@delegation.id})")
  end
end