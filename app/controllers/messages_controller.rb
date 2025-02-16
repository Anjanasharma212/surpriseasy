class MessagesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_group
  before_action :check_participant, only: [:index, :create]

  def index
    @messages = @group.messages.includes(:sender).order(created_at: :asc)
    render json: @messages.map{|msg| format_message(msg)}
  end

  def create 
    @message = @group.messages.new(
      sender: current_user,
      message: params[:message]
    )

    if @message.save
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
      sender_name: msg.sender.name,
      message: msg.message,
      sent_at: msg.created_at
    }
  end
end
