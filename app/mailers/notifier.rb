class Notifier < ApplicationMailer
  default from: ENV['EMAIL_USER']

  RECIPIENTS = Rails.application.secrets.recipients

  def notify(subject, body)
    @body = body
    mail(to: RECIPIENTS, subject: subject)
  end
end
