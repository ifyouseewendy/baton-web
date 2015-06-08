class Notifier < ApplicationMailer
  default from: "wendi@example.com"

  RECIPIENTS = Rails.application.secrets.recipients

  def notify(subject, body)
    @body = body
    mail(to: RECIPIENTS, subject: subject)
  end
end
