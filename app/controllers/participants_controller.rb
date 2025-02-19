class ParticipantsController < ApplicationController
  before_action :set_participant, only: [:my_drawn_name]

  def my_drawn_name
    case request.method_symbol
    when :get
      handle_get_request
    when :post
      handle_post_request
    else
      render json: { error: "Unsupported request method." }, status: :method_not_allowed
    end
  end

  private

  def handle_get_request
    drawn_participant = @participant.drawn_name
  
    respond_to do |format|
      format.html
      format.json do
        if drawn_participant
          render json: participant_json(drawn_participant)
        else
          render json: { error: "No drawn name assigned yet." }, status: :ok
        end
      end
    end
  end
  
  def handle_post_request
    if @participant.drawn_name
      return render json: { error: "You have already drawn a name." }, status: :unprocessable_entity
    end
  
    all_participants = Participant.where(group_id: @participant.group_id)
    if all_participants.where(drawn_name_id: nil).empty?
      return render json: { error: "No available participants left." }, status: :unprocessable_entity
    end
  
    assign_drawn_names(all_participants)
  
    drawn_participant = @participant.reload.drawn_name

    respond_to do |format|
      format.html { redirect_to participant_path(@participant), notice: "Drawn name assigned!" }
      format.json { render json: participant_json(drawn_participant) }
    end
  end

  def assign_drawn_names(participants)
    shuffled_participants = participants.shuffle
  
    shuffled_participants.each_with_index do |participant, index|
      next_participant = shuffled_participants[(index + 1) % shuffled_participants.size]
      participant.update(drawn_name: next_participant)
    end
  end

  def participant_json(drawn_participant)
    {
      participant_id: @participant.id,
      group_id: @participant.group_id,
        drawn_name: drawn_participant ? { 
        id: drawn_participant.user.id, 
        name: drawn_participant.user.name 
      } : nil
    }
  end

  def set_participant
    @participant = Participant.find_by(id: params[:id])
    unless @participant
      render json: { error: "Participant not found" }, status: 404
    end
  end
end
