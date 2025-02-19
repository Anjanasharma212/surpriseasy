class MessagesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_group
  before_action :check_participant, only: [:index, :create]

  def index
    @messages = @group.messages.includes(:sender).where(is_anonymous: false).order(created_at: :asc)
    render json: @messages.map{|msg| format_message(msg)}
  end

  def create 
    is_anonymous = params[:is_anonymous].to_s == "true"
    receiver = User.find_by(id: params[:receiver_id]) if is_anonymous

    if is_anonymous && (!receiver || !@group.users.include?(receiver))
      return render json: { error: "Invalid recipient" }, status: :unprocessable_entity
    end

    @message = @group.messages.new(
      sender: current_user,
      receiver: receiver,
      message: params[:message],
      is_anonymous: is_anonymous  
    )   

    if @message.save 
      MessageJob.perform_later(@message.id) if @message.is_anonymous?
      render json: format_message(@message), status: :created
    else
      render json: { error: "Message could not be sent" }, status: :unprocessable_entity
    end
  end

  private

  def set_group
    @group = Group.find(params[:group_id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Group not found" }, status: :not_found
  end

  def check_participant
    unless @group.users.include?(current_user)
      render json: { error: "You are not a participant in this group" }, status: :forbidden
    end
  end

  def format_message(msg)
    {
      id: msg.id,   
      sender_name: msg.is_anonymous? ? "Anonymous" : msg.sender.name,
      message: msg.message,
      receiver_id: msg.receiver_id,
      sent_at: msg.created_at
    }
  end
end
