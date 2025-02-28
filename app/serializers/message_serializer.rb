class MessageSerializer < ActiveModel::Serializer
  attributes :id, :content, :sender_name, :sent_at, :is_anonymous, :receiver_id, :success_message

  def sender_name
    object.is_anonymous? ? "Anonymous" : object.sender.name
  end

  def sent_at
    object.created_at.iso8601 if object.created_at
  end

  def success_message
    instance_options[:success_message] || I18n.t('groups.success.message_sent')
  end

  def receiver_id
    object.receiver_id if object.receiver_id.present?
  end
end 
