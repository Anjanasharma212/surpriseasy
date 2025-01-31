class GroupsController < ApplicationController
  # before_action :authenticate_user!
  
  def gift_generator;end

  def index
    @groups = Group.includes(participants: { user: { wishlists: :items } }).all
  end 

  def create
    @group = Group.new(group_params)

    if @group.save
      render json: { success: "Group created successfully!"}, status: :created
    else
      render json: { errors: @group.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private 

  def group_params
    params.require(:group).permit(
      :group_name, 
      :event_date, 
      :budget, 
      :message, 
      user_attributes: [:email, :name], 
      participants_attributes: [user_attributes: [:email]]
    )
  end
end
