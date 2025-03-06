class MessagesController < ApplicationController
  before_action :set_group
  before_action :check_participant, only: [:index, :create]

  rescue_from ActiveRecord::RecordInvalid, with: :handle_invalid_record
  rescue_from ActiveRecord::RecordNotFound, with: :handle_not_found

  def index
    @messages = @group.messages
      .includes(:sender)
      .not_anonymous

    render json: @messages.map { |msg| format_message(msg) }
  end

  def create
    @message = @group.messages.new(message_params.merge(sender: current_user))
    @message.save!

    if @message.is_anonymous?
      begin
        MessageJob.perform_later(@message.id)
      rescue StandardError
        return render json: {
          message: @message,
          warning: t('groups.messages.warnings.notification_delayed')
        }, status: :created
      end
    end

    render json: @message, status: :created
  end

  private

  def set_group
    @group = Group.find(params[:group_id])
  end

  def check_participant
    unless @group.participants.exists?(user_id: current_user.id)
      render json: { error: I18n.t('groups.errors.not_participant') }, status: :forbidden
    end
  end

  def message_params
    params.require(:message).permit(:content, :receiver_id, :is_anonymous)
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

  def handle_invalid_record(exception)
    render json: { error: exception.record.errors.full_messages }, 
           status: :unprocessable_entity
  end

  def handle_not_found
    render json: { error: I18n.t('groups.errors.not_found') }, status: :not_found
  end
end
