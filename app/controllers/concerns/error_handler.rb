module ErrorHandler
  extend ActiveSupport::Concern

  included do
    rescue_from StandardError, with: :handle_standard_error
    rescue_from ActiveRecord::RecordNotFound, with: :handle_not_found
    rescue_from ActionController::BadRequest, with: :handle_bad_request
    rescue_from ActionController::ParameterMissing, with: :handle_parameter_missing
    rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
    rescue_from ActiveRecord::RecordInvalid, with: :handle_record_invalid
    rescue_from ActiveRecord::DeleteRestrictionError, with: :handle_delete_restriction
  end

  private

  def handle_not_found(exception)
    model_name = exception.model.underscore.tr('/', '.')
    error_message = I18n.t("#{model_name.pluralize}.errors.not_found", 
                          default: I18n.t('errors.record_not_found'))
    render_error(error_message, :not_found)
  end

  def handle_standard_error(exception)
    render_error(exception.message)
  end

  def handle_bad_request
    render_error(I18n.t('errors.invalid_format'), :bad_request)
  end

  def handle_parameter_missing
    render_error(I18n.t('errors.parameter_missing'), :bad_request)
  end

  def user_not_authorized
    respond_to do |format|
      format.html do
        flash[:alert] = I18n.t('errors.not_authorized')
        redirect_back(fallback_location: root_path)
      end
      format.json { render_error(I18n.t('errors.not_authorized'), :forbidden) }
    end
  end

  def handle_record_invalid(exception)
    render_error(exception.record.errors.full_messages.to_sentence, :unprocessable_entity)
  end

  def handle_delete_restriction(exception)
    render_error(I18n.t('errors.deletion_failed'), :unprocessable_entity)
  end

  def render_error(message, status = :unprocessable_entity)
    respond_to do |format|
      format.html { 
        redirect_to root_path, 
        alert: message 
      }
      format.json { 
        render json: { 
          error: message 
        }, 
        status: status 
      }
    end
  end

  def render_success(options = {})
    respond_to do |format|
      format.html { 
        redirect_to options[:redirect_path], 
        notice: options[:notice] 
      }
      format.json { 
        render json: options[:data], 
        status: options[:status] || :ok 
      }
    end
  end

  def render_json_success(data, status = :ok)
    render json: data, status: status
  end

  def render_json_error(message, status = :unprocessable_entity)
    render json: { error: message }, status: status
  end
end 
