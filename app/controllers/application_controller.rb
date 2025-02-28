class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  before_action :authenticate_user!
  allow_browser versions: :modern
  protect_from_forgery with: :exception

  rescue_from ActionController::BadRequest, with: :handle_bad_request
  rescue_from ActionController::ParameterMissing, with: :handle_parameter_missing

  private

  def handle_bad_request(exception)
    render json: { error: I18n.t('groups.errors.invalid_format') }, 
           status: :bad_request
  end

  def handle_parameter_missing(exception)
    render json: { error: I18n.t('groups.errors.parameter_missing') }, 
           status: :bad_request
  end
end
