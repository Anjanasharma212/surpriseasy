class UserMailer < ApplicationMailer
  default from: 'Anonymous'

  def anonymous_message(message)
    return unless message.present? && message.is_anonymous? && message.receiver.present?

    @message_content = message.content

    mail(
      to: message.receiver.email,
      subject: "You've received an anonymous message"
    )
  end
end
