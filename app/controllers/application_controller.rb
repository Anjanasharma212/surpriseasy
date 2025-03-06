class ApplicationController < ActionController::Base
  include Pundit::Authorization
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  before_action :authenticate_user!
  allow_browser versions: :modern
  protect_from_forgery with: :exception

  rescue_from ActionController::BadRequest, with: :handle_bad_request
  rescue_from ActionController::ParameterMissing, with: :handle_parameter_missing
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  rescue_from ActiveRecord::RecordNotFound, with: :handle_not_found

  def pundit_user
    current_user
  end

  private

  def handle_bad_request(exception)
    render json: { error: I18n.t('groups.errors.invalid_format') }, 
           status: :bad_request
  end

  def handle_parameter_missing(exception)
    render json: { error: I18n.t('groups.errors.parameter_missing') }, 
           status: :bad_request
  end

  def handle_not_found
    respond_to do |format|
      format.html { 
        redirect_to root_path, 
        alert: I18n.t('errors.record_not_found') 
      }
      format.json { 
        render json: { 
          error: I18n.t('errors.record_not_found') 
        }, status: :not_found 
      }
    end
  end

  def user_not_authorized
    flash[:alert] = I18n.t('errors.not_authorized')
    redirect_back(fallback_location: root_path)
  end
end
