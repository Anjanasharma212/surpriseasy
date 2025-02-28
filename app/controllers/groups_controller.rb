class GroupsController < ApplicationController
  before_action :set_group, only: [:show, :destroy]
  before_action :authorize_group_access, only: [:show]
  rescue_from ActiveRecord::RecordNotFound, with: :handle_record_not_found

  def group_generator;end

  def index
    @groups = current_user.participant_groups
    
    respond_to do |format|
      format.html
      format.json { render_groups_list }
    end
  end

  def show
    respond_to do |format|
      format.html
      format.json { render_group_details }
    end
  end

  def create
    @group = Group.new(group_params)

    if @group.save
      begin
        GroupEmailJob.perform_later(@group.id)
        render json: { success: t('groups.success.created') }, status: :created
      rescue StandardError => e
        render json: { 
          success: t('groups.success.created'),
          warning: t('groups.warnings.email_delayed')
        }, status: :created
      end
    else
      render json: { errors: @group.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    result = GroupService.new(@group).remove
    
    if result[:success]
      render json: { message: result[:message] }, status: :ok
    else
      render json: { error: result[:error] }, status: :unprocessable_entity
    end
  end

  private

  def render_groups_list
    if @groups.exists?
      render json: @groups.map { |group| GroupSerializer.new(group, current_user).format_group_details }
    else
      render_not_found(t('groups.errors.no_groups'))
    end
  end

  def render_group_details
    render json: GroupSerializer.new(@group, current_user).format_group_details
  end

  def render_not_found(message)
    render json: { error: message }, status: :not_found
  end
  
  def set_group
    @group = Group.includes(group_includes).find(params[:id])
  end

  def authorize_group_access
    unless @group&.participants&.exists?(user_id: current_user.id)
      render json: { error: t('groups.errors.unauthorized') }, status: :forbidden
    end
  end
  
  def group_params
    params.require(:group).permit(
      :group_name, 
      :event_date, 
      :budget, 
      :message, 
      user_attributes: [:email, :name], 
      participants_attributes: [user_attributes: [:email, :name]]
    )
  end

  def group_includes
    {
      participants: {
        user: {},
        wishlists: {
          wishlist_items: :item
        }
      }
    }
  end

  def handle_record_not_found
    render json: { error: t('groups.errors.not_found') }, status: :not_found
  end
end
