module AuthenticationHelper
  def setup_devise
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  def create_and_sign_in_user
    setup_devise
    user = create(:user, :invitation_accepted)
    sign_in(user)
    user
  end
end

RSpec.configure do |config|
  config.include AuthenticationHelper, type: :controller
  config.include Devise::Test::ControllerHelpers, type: :controller
end 
