class ApplicationController < ActionController::Base
  include Pundit::Authorization
  include ErrorHandler
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  before_action :authenticate_user!
  allow_browser versions: :modern
  protect_from_forgery with: :exception

  def pundit_user
    current_user
  end

  private

  def after_sign_out_path_for(resource_or_scope)
    new_user_session_path
  end
end
