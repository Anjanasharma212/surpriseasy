class GroupsController < ApplicationController
  before_action :authenticate_user!

  def gift_generator;end

  def index
    @groups = Group.joins(:participants).where(participants: { user_id: current_user.id }).includes(participants: :user)
  
    respond_to do |format|
      format.html
      format.json {
        render json: @groups.to_json(
          include: {participants: {include: { user: { only: [:id, :name, :email] } }}}
        )
      }
    end
  end
  
  def show
    @group = Group.includes(participants: { user: {}, wishlists: { wishlist_items: :item } }).find(params[:id])
    unless @group.participants.exists?(user_id: current_user.id)
      return render json: { error: "You are not authorized to view this group" }, status: :forbidden
    end

    respond_to do |format|
      format.html
      format.json { render json: group_json(@group, current_user) }
    end
  end

  def create
    binding.pry
    @group = Group.new(group_params)

    if @group.save
      GroupEmailJob.perform_later(@group.id)
      render json: { success: "Group created successfully!"}, status: :created
    else
      render json: { errors: @group.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private 

  def group_json(group, current_user)
    participant = group.participants.find_by(user_id: current_user.id)

    {
      id: group.id,
      name: group.group_name,
      event_date: group.event_date,
      budget: group.budget,
      logged_in_participant: participant ? {
        name: participant.user.name,
        email: participant.user.email
      } : nil,
      participants: group.participants.map do |participant|
        wishlist = participant.wishlists.first 

        {
          participant_id: participant.id,
          email: participant.user.email,
          wishlist_id: wishlist ? wishlist.id : nil,
          wishlist_items_count: wishlist ? wishlist.wishlist_items.count : 0,
          wishlist_items: wishlist ? wishlist.wishlist_items.map do |wishlist_item|
            {
              id: wishlist_item.item.id,
              item_name: wishlist_item.item.item_name,
              image_url: wishlist_item.item.image_url
            }
          end : []
        }
      end
    }
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
