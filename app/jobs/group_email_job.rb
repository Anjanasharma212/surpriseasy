class GroupEmailJob < ApplicationJob
  queue_as :default

  def perform(group_id)
    group = Group.find(group_id)

    GroupMailer.group_created_email(group.user, group).deliver_later

    group.users.each do |participant| 
      GroupMailer.group_created_email(participant, group).deliver_later
    end
  end
end
