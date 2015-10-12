class InvitationNotifier < ActionMailer::Base

  def setup_email(recipient)
    mail(to: recipient,
         from: Powernode.config.smtp_from_email,
         subject: I18n.t('notifier.invitation.subject'))
  end

  def invitation(invitation)
    @invitation = invitation
    setup_email(invitation.recipient)
  end
end
