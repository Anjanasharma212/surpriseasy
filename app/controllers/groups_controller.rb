class GroupsController < ApplicationController

  def gift_generator;end

  def index
    @groups = Group.includes(participants: { user: { wishlists: :items } }).all
  end 

  def create
    # binding.pry
    @group = Group.new(group_params.except(:participants))

    if @group.save
      params[:group][:participants].each do |participant_user_id|
        @group.participants.create(user_id: participant_user_id)
      end
      render json: { success: "Group created successfully!" }, status: :created
    else
      render json: { errors: @group.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private 
  def group_params 
    params.require(:group).permit(:group_name, :user_id, :budget, :event_name, :event_date, :group_code, :message, participants: [])
  end 
end
