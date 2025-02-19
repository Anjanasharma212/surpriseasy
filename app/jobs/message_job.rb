class MessageJob < ApplicationJob
  queue_as :default

  def perform(message_id)
    message = Message.find_by(id: message_id)
    return unless message.present? && message.is_anonymous? && message.receiver.present?

    UserMailer.anonymous_message(message).deliver_now
  end
end
