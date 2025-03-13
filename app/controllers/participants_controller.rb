class ParticipantsController < ApplicationController
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
      render_success(
        redirect_path: participant_path(@participant),
        notice: I18n.t('participants.success.name_drawn'),
        data: result[:participant]
      )
    else
      render_error(result[:error])
    end
  end

  private

  def set_participant
    @participant = Participant.includes(:drawn_name, :user, wishlists: { wishlist_items: :item })
                            .find(params[:id])
  end

  def render_participant_json
    if @participant.drawn_name
      render_json_success(ParticipantSerializer.new(@participant).format_participant_details)
    else
      render_json_error(I18n.t('participants.errors.no_drawn_name'), :ok)
    end
  end
end
