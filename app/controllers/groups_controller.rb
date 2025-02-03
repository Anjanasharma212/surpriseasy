class GroupsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_group, only: [:show]

  def gift_generator;end

  def index
    # @groups = Group.includes(participants: { user: { wishlists: :items } }).all
    # @groups = current_user.groups
    # render json: @groups
  end 

  def show
    binding.pry
    @group = current_user.groups.find(params[:id])
    render json: {
      user_email: current_user.email,
      group_name: @group.group_name,
      event_date: @group.event_date,
      amount: @group.budget
    }
  end 

  def create
    @group = Group.new(group_params)

    if @group.save
      GroupEmailJob.perform_later(@group.id)
      render json: { success: "Group created successfully!"}, status: :created
    else
      render json: { errors: @group.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private 

  def set_group
    @group = Group.find(params[:id])
  end

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
