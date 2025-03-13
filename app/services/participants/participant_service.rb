module Participants
  class ParticipantService
    def initialize(participant)
      @participant = participant
    end

    def draw_name
      ActiveRecord::Base.transaction do
        validate_drawing_eligibility
        perform_name_drawing
        success_response
      end
    rescue StandardError => e
      failure_response(e.message)
    end

    private

    def validate_drawing_eligibility
      check_existing_drawn_name
      check_minimum_participants
      check_available_participants
    end

    def check_existing_drawn_name
      return unless @participant.drawn_name.present?
      raise StandardError, I18n.t('participants.errors.already_drawn')
    end

    def check_minimum_participants
      total_participants = get_group_participants.count
      if total_participants < 2
        raise StandardError, I18n.t('participants.errors.minimum_participants_required')
      end
    end

    def check_available_participants
      available = available_participants
      return if available.exists?
      raise StandardError, I18n.t('participants.errors.no_available_participants')
    end

    def available_participants
      get_group_participants
        .includes(:user, :drawn_name, wishlists: { wishlist_items: :item })
        .where.not(id: @participant.id)
        .where(drawn_name_id: nil)
    end

    def get_group_participants
      Participant.where(group_id: @participant.group_id)
    end

    def perform_name_drawing
      shuffled_participants = get_group_participants.shuffle
      create_drawing_circle(shuffled_participants)
      @participant.reload
    end

    def create_drawing_circle(participants)
      ActiveRecord::Base.transaction do
        participants.each_with_index do |participant, index|
          assign_next_participant(participant, participants, index)
        end
      end
    end

    def assign_next_participant(participant, participants, index)
      if participants.nil? || participants.size < 2
        raise StandardError, I18n.t('participants.errors.invalid_participants')
      end
      
      next_participant = participants[(index + 1) % participants.size]
      participant.update!(drawn_name: next_participant)
    end

    def success_response
      {
        success: true,
        participant: ParticipantSerializer.new(@participant).format_participant_details
      }
    end

    def failure_response(error_message)
      {
        success: false,
        error: error_message
      }
    end
  end
end 
