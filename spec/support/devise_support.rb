module DeviseSupport
  def login_user
    let(:user) { create(:user) }

    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      @request.session = ActionController::TestSession.new
      manager = Warden::Manager.new(nil) do |config|
        config.default_strategies(scope: :user).unshift :database_authenticatable
        config.failure_app = Devise::FailureApp
      end

      warden = Warden::Proxy.new(@request.env, manager)
      warden.set_user(user, scope: :user)
      @request.env['warden'] = warden

      sign_in(user, scope: :user)

      allow(controller).to receive(:current_user).and_return(user)
      allow(controller).to receive(:user_signed_in?).and_return(true)
      allow(request.env['warden']).to receive(:authenticate!).and_return(user)
      allow(request.env['warden']).to receive(:authenticate).and_return(user)
    end
  end
end 
