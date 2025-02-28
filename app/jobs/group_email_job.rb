class GroupEmailJob < ApplicationJob
  queue_as :default
  retry_on StandardError, wait: 5.seconds, attempts: 3
  
  def perform(group_id)
    group = Group.find(group_id)

    group.participants.includes(:user).each do |participant|
      next unless participant.user&.email.present?
      send_email(participant.user, group)
    end
  end

  private

  def send_email(user, group)
    GroupMailer.group_created_email(user, group).deliver_later
  rescue StandardError => e
    raise # Re-raise to trigger retry
  end
end
