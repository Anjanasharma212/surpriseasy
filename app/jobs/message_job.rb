class MessageJob < ApplicationJob
  queue_as :default
  retry_on StandardError, wait: 5.seconds, attempts: 3

  def perform(message_id)
    message = Message.find(message_id)
    return unless message.is_anonymous? && message.receiver.present?

    UserMailer.anonymous_message(message).deliver_now
  rescue StandardError => e
    # Rails.logger.error(I18n.t('groups.messages.errors.job_processing_failed', error: e.message))
    raise
  end
end
