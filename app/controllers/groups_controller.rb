class GroupsController < ApplicationController
  before_action :set_group, only: [:show, :update, :destroy]
  rescue_from ActiveRecord::RecordNotFound, with: :handle_record_not_found
  rescue_from StandardError, with: :handle_standard_error

  def group_generator
    render :group_generator
  end

  def index
    @groups = policy_scope(Group)
    
    respond_to do |format|
      format.html
      format.json { render_groups_list }
    end
  end

  def show
    authorize @group
    group_details = GroupSerializer.new(@group, current_user).format_group_details
    respond_to do |format|
      format.html
      format.json { render json: group_details }
    end
  end

  def create
    @group = Group.new(group_params)
    @group.user = current_user
    authorize @group

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

  def update
    authorize @group
    if @group.update(group_params)
      respond_to do |format|
        format.html { redirect_to @group, notice: t('groups.success.updated') }
        format.json { render json: @group }
      end
    else
      respond_to do |format|
        format.html { render :edit }
        format.json { render json: @group.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    authorize @group
    if @group.destroy
      head :no_content
    else
      render json: { error: t('groups.errors.delete_failed') }, status: :unprocessable_entity
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

  def render_not_found(message)
    render json: { error: message }, status: :not_found
  end
  
  def set_group
    @group = Group.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    handle_record_not_found
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

  def handle_standard_error(exception)
    respond_to do |format|
      format.html { redirect_to groups_path, alert: 'An error occurred.' }
      format.json { render json: { error: 'An error occurred while processing your request.' }, status: :internal_server_error }
    end
  end

  def handle_record_not_found
    render json: { error: t('groups.errors.not_found') }, status: :not_found
  end
end
