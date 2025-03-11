class ParticipantsController < ApplicationController
  rescue_from StandardError, with: :render_error
  rescue_from ActiveRecord::RecordNotFound, with: :handle_not_found

  before_action :set_participant, only: [:show, :update]

  def show
    respond_to do |format|
      format.html
      format.json { render_participant_json }
    end
  end

  def update
    result = Participants::ParticipantService.new(@participant).draw_name

    if result[:success]
      handle_success_response(result)
    else
      handle_error_response(result)
    end
  end

  private

  def set_participant
    # @participant = Participant.find(params[:id])
    @participant = Participant.includes(:drawn_name, :user, wishlists: { wishlist_items: :item })
                            .find(params[:id])
  end

  def handle_success_response(result)
    respond_to do |format|
      format.html { 
        redirect_to participant_path(@participant), 
        notice: I18n.t('participants.success.name_drawn') 
      }
      format.json { render json: result[:participant] }
    end
  end

  def handle_error_response(result)
    render json: { error: result[:error] }, 
           status: :unprocessable_entity
  end

  def render_participant_json
    if @participant.drawn_name
      render json: ParticipantSerializer.new(@participant).format_participant_details
    else
      render json: { error: I18n.t('participants.errors.no_drawn_name') }, 
             status: :ok
    end
  end

  def handle_not_found
    render json: { error: I18n.t('participants.errors.not_found') }, 
           status: :not_found
  end

  def render_error(error)
    render json: { error: error.message }, 
           status: :unprocessable_entity
  end
end
