class MessagesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_group
  before_action :check_participant, only: [:index, :create]

  def index
    @messages = @group.messages.includes(:sender).where(is_anonymous: false).order(created_at: :asc)
    render json: @messages.map{|msg| format_message(msg)}
  end

  def create
    @message = @group.messages.new(message_params.merge(sender: current_user))

    if @message.save
      MessageJob.perform_later(@message.id) if @message.is_anonymous?
      render json: { success: "Message sent successfully!", message: format_message(@message) }, status: :created
    else
      render json: { errors: @message.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def set_group
    @group = Group.find_by(id: params[:group_id])
    render json: { error: "Group not found" }, status: :not_found unless @group
  end

  def check_participant
    return if @group.users.include?(current_user)

    render json: { error: "You are not a participant in this group" }, status: :forbidden
  end

  def message_params
    if params[:message].is_a?(String)
      Rails.logger.error "Expected params[:message] to be a Hash, but got String: #{params[:message].inspect}"
      raise ActionController::BadRequest, "Invalid parameters format"
    end
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
end
