class MessagesController < ApplicationController
  before_action :set_group
  before_action :check_participant, only: [:index, :create]

  def index
    @messages = @group.messages
      .includes(:sender)
      .not_anonymous

    render json: @messages.map { |msg| format_message(msg) }
  end

  def create
    @message = @group.messages.new(message_params.merge(sender: current_user))
    
    if @message.save
      handle_anonymous_message
      render json: @message, status: :created
    else
      render_error(@message.errors.full_messages.to_sentence)
    end
  end

  private

  def set_group
    @group = Group.find(params[:group_id])
  end

  def check_participant
    unless @group.participants.exists?(user_id: current_user.id)
      render_error(I18n.t('groups.errors.not_participant'), :forbidden)
    end
  end

  def message_params
    params.require(:message).permit(:content, :receiver_id, :is_anonymous)
  end

  def handle_anonymous_message
    MessageJob.perform_later(@message.id) if @message.is_anonymous?
  rescue StandardError => e
    render_error(I18n.t('groups.messages.warnings.notification_delayed'), :created)
  end

  def format_message(msg)
    {
      id: msg.id,
      sender_name: msg.is_anonymous? ? "Anonymous" : msg.sender.name,
      content: msg.content,
      receiver_id: msg.receiver_id,
      sent_at: msg.created_at
    }
  end
end
