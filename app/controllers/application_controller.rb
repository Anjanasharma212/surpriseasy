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

  def handle_bad_request
    respond_to do |format|
      format.html { redirect_to root_path, alert: I18n.t('errors.invalid_format') }
      format.json { render json: { error: I18n.t('errors.invalid_format') }, status: :bad_request }
    end
  end

  def handle_parameter_missing
    respond_to do |format|
      format.html { redirect_to root_path, alert: I18n.t('errors.parameter_missing') }
      format.json { render json: { error: I18n.t('errors.parameter_missing') }, status: :bad_request }
    end
  end

  def handle_not_found
    respond_to do |format|
      format.html { redirect_to root_path, alert: I18n.t('errors.group.not_found') }
      format.json { render json: { error: I18n.t('errors.group.not_found') }, status: :not_found }
    end
  end

  def user_not_authorized
    respond_to do |format|
      format.html { redirect_to root_path, alert: I18n.t('errors.not_authorized') }
      format.json { render json: { error: I18n.t('errors.not_authorized') }, status: :forbidden }
    end
  end
end
