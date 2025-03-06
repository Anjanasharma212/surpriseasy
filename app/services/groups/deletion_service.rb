module Groups
  class DeletionService
    def initialize(group)
      @group = group
    end
  
    def execute
      ActiveRecord::Base.transaction do
        clear_drawn_references
        @group.destroy!
        success_response
      rescue => e
        failure_response(I18n.t('groups.errors.delete_failed'))
      end
    end
  
    private
  
    def clear_drawn_references
      @group.participants.update_all(drawn_name_id: nil)
    end
  
    def success_response
      { success: true, message: I18n.t('groups.success.deleted') }
    end
  
    def failure_response(error_message)
      { success: false, error: error_message }
    end
  end
end 
