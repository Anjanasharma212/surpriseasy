require 'rails_helper'

RSpec.describe GroupsController, type: :controller do
  include Devise::Test::ControllerHelpers
  
  login_user
  
  let(:group) do 
    create(:group, :with_participants, user: controller.current_user)
  end

  let(:valid_attributes) do
    {
      group_name: "New Test Group",
      event_date: Date.tomorrow,
      budget: 1000,
      message: "Welcome to the group!"
    }
  end

  before(:each) do
    @request.session = ActionController::TestSession.new
    allow(controller).to receive(:policy_scope).with(Group).and_return(Group.all)
    allow(controller).to receive(:authorize).with(any_args).and_return(true)

    allow_any_instance_of(GroupSerializer).to receive(:format_group_details).and_return({
      id: group&.id || 1,
      group_name: "Test Group",
      event_date: Date.tomorrow.to_s,
      budget: 1000,
      message: "Welcome!",
      participants: []
    })
  end

  describe "GET #index" do
    it "returns a successful response" do
      get :index
      expect(response).to be_successful
    end

    context "JSON format" do
      it "returns groups when they exist" do
        group
        get :index, format: :json
        expect(response).to be_successful
        json = JSON.parse(response.body)
        expect(json).to be_an(Array)
        expect(json).not_to be_empty
      end

      it "returns empty array when no groups" do
        Group.destroy_all
        empty_scope = Group.none
        allow(controller).to receive(:policy_scope).with(Group).and_return(empty_scope)
        allow(controller).to receive(:authorize).with(:index, Group).and_return(true)

        serializer_instance = instance_double(GroupSerializer)
        allow(GroupSerializer).to receive(:new).and_return(serializer_instance)
        allow(serializer_instance).to receive(:format_group_details).and_return({})
        
        get :index, format: :json
        expect(response).to have_http_status(404)
        json = JSON.parse(response.body)
        expect(json).to eq({ "error" => "No groups found. Create your first group!" })
      end
    end
  end

  describe "GET #group_generator" do
    it "renders the group_generator template" do
      get :group_generator
      expect(response).to be_successful
      expect(response).to render_template(:group_generator)
    end
  end

  describe "GET #show" do
    it "returns a successful response" do
      get :show, params: { id: group.id }
      expect(response).to be_successful
    end

    it "returns group as JSON" do
      get :show, params: { id: group.id }, format: :json
      expect(response).to be_successful
      json = JSON.parse(response.body)
      expect(json["group_name"]).to eq("Test Group")
    end

    it "returns 404 for non-existent group" do
      get :show, params: { id: 999999 }
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST #create" do
    it "creates a new group with valid params" do
      expect {
        post :create, params: { group: valid_attributes }
      }.to change(Group, :count).by(1)
      expect(response).to have_http_status(:created)
    end

    it "enqueues an email job" do
      expect {
        post :create, params: { group: valid_attributes }
      }.to have_enqueued_job(GroupEmailJob)
    end

    it "fails with invalid params" do
      allow_any_instance_of(Group).to receive(:save).and_return(false)
      
      post :create, params: { group: { group_name: "" } }
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "PATCH #update" do
    let(:update_group) { create(:group, user: controller.current_user) }
    
    before do
      allow(controller).to receive(:authorize).with(update_group).and_return(true)
    end

    it "updates the group" do
      allow(Group).to receive(:find).with(update_group.id.to_s).and_return(update_group)
      
      patch :update, params: { 
        id: update_group.id, 
        group: { group_name: "Updated Name" } 
      }, format: :json
      
      expect(response).to be_successful
      update_group.reload
      expect(update_group.group_name).to eq("Updated Name")
    end

    it "fails with invalid params" do
      allow_any_instance_of(Group).to receive(:update).and_return(false)
      allow(Group).to receive(:find).with(update_group.id.to_s).and_return(update_group)
      
      allow(controller).to receive(:authorize).with(update_group).and_return(true)
      
      patch :update, params: { 
        id: update_group.id, 
        group: { group_name: "" } 
      }, format: :json
      
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "DELETE #destroy" do
    it "deletes the group" do
      group_to_delete = create(:group, user: subject.current_user)
      expect {
        delete :destroy, params: { id: group_to_delete.id }
      }.to change(Group, :count).by(-1)
      expect(response).to have_http_status(:no_content)
    end

    it "returns error when delete fails" do
      allow_any_instance_of(Group).to receive(:destroy).and_return(false)
      delete :destroy, params: { id: group.id }
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "Error Handling" do
    it "handles general errors" do
      allow(Group).to receive(:find).with('invalid').and_raise(
        ActiveRecord::RecordNotFound.new("Couldn't find Group")
      )
      
      get :show, params: { id: 'invalid' }, format: :json
      expect(response).to have_http_status(:not_found)
      json = JSON.parse(response.body)
      expect(json["error"]).to eq(I18n.t('errors.group.not_found'))
    end

    it "handles record not found" do
      get :show, params: { id: "nonexistent" }
      expect(response).to have_http_status(:not_found)
      json = JSON.parse(response.body)
      expect(json["error"]).to eq(I18n.t('errors.group.not_found'))
    end
  end
  
  describe "Authorization" do
    context "when user is not signed in" do
      before do
        sign_out :user
        @request.env['devise.mapping'] = Devise.mappings[:user]
        @request.session = ActionController::TestSession.new
        @request.env['warden'] = double(
          authenticate?: false,
          authenticated?: false,
          user: nil,
          message: nil
        )
        allow(controller).to receive(:user_signed_in?).and_return(false)
        allow(controller).to receive(:current_user).and_return(nil)
        
        allow(controller).to receive(:authenticate_user!).and_raise(
          Devise::FailureApp.new.tap do |app|
            app.default_url_options = { host: 'test.host' }
          end
        )
      end

      it "redirects to login for protected actions" do
        expect {
          get :index
        }.to raise_error { |error|
          expect(error).to be_a(Devise::FailureApp)
        }
      end
    end

    context "when accessing another user's group" do
      let(:other_user) { create(:user) }
      let(:other_group) { create(:group, user: other_user) }

      before do
        @user = controller.current_user
        sign_in @user
        
        allow(Group).to receive(:find).with(other_group.id.to_s).and_return(other_group)
        mock_policy = instance_double(GroupPolicy)
        allow(mock_policy).to receive(:show?).and_return(false)
        allow(controller).to receive(:policy).with(other_group).and_return(mock_policy)
        
        allow(controller).to receive(:authorize).with(other_group) do
          raise Pundit::NotAuthorizedError.new("not allowed")
        end
      end

      it "prevents unauthorized access" do
        get :show, params: { id: other_group.id }, format: :json
        expect(response).to have_http_status(:forbidden)
        json = JSON.parse(response.body)
        expect(json["error"]).to eq(I18n.t('errors.not_authorized'))
      end
    end
  end

  describe "POST #create with nested attributes" do
    let(:valid_nested_attributes) do
      {
        group_name: "Test Group",
        event_date: Date.tomorrow,
        budget: 1000,
        message: "Welcome!",
        user_attributes: {
          email: "new@example.com",
          name: "New User"
        },
        participants_attributes: [
          { user_attributes: { email: "participant@example.com", name: "Participant" } }
        ]
      }
    end

    it "creates group with nested user and participants" do
      expect {
        post :create, params: { group: valid_nested_attributes }
      }.to change(Group, :count).by(1)
        .and change(Participant, :count).by(1)
      
      expect(response).to have_http_status(:created)
    end

    it "handles invalid nested attributes" do
      invalid_attrs = valid_nested_attributes
      invalid_attrs[:participants_attributes][0][:user_attributes][:email] = "invalid"

      post :create, params: { group: invalid_attrs }
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "Response formats" do
    describe "GET #show" do
      context "when requesting HTML" do
        it "renders the show template" do
          get :show, params: { id: group.id }
          expect(response).to render_template(:show)
        end
      end

      context "when requesting JSON" do
        it "returns properly formatted JSON" do
          get :show, params: { id: group.id }, format: :json
          json = JSON.parse(response.body)
          
          expect(json).to include(
            "id",
            "group_name",
            "event_date",
            "budget",
            "message"
          )
        end
      end
    end
  end

  describe "Error handling" do
    context "when group creation fails" do
      before do
        allow_any_instance_of(Group).to receive(:save).and_return(false)
      end

      it "returns appropriate error response" do
        post :create, params: { group: valid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "when email job fails" do
      before do
        allow(GroupEmailJob).to receive(:perform_later).and_raise(StandardError)
      end

      it "still creates group but includes warning" do
        post :create, params: { group: valid_attributes }
        json = JSON.parse(response.body)
        expect(json).to include("warning")
        expect(response).to have_http_status(:created)
      end
    end
  end

  describe "Participant management" do
    let(:participant) { create(:participant, group: group) }

    it "includes participants in group details" do
      participant
      get :show, params: { id: group.id }, format: :json
      
      json = JSON.parse(response.body)
      expect(json).to have_key("participants")
    end
  end

  describe "Message handling" do
    it "includes group message in creation" do
      post :create, params: { 
        group: valid_attributes.merge(message: "Custom welcome message") 
      }
      
      new_group = Group.last
      expect(new_group.message).to eq("Custom welcome message")
    end
  end

  describe "PATCH #update" do
    context "with nested attributes" do
      let(:update_attributes) do
        {
          group_name: "Updated Name",
          participants_attributes: [
            { user_attributes: { email: "new_participant@example.com", name: "New Person" } }
          ]
        }
      end

      it "updates group and adds new participants" do
        expect {
          patch :update, params: { id: group.id, group: update_attributes }
        }.to change(Participant, :count).by(1)

        group.reload
        expect(group.group_name).to eq("Updated Name")
      end
    end
  end

  describe "Group scoping" do
    let(:other_user) { create(:user) }
    let(:other_group) { create(:group, user: other_user) }
    let(:visible_groups) { Group.where(user: controller.current_user) }

    before do
      allow(controller).to receive(:policy_scope).with(Group).and_return(visible_groups)
      allow(controller).to receive(:authorize).with(:index, Group).and_return(true)
    end

    it "only returns groups visible to current user" do
      other_group
      get :index
      expect(assigns(:groups)).to match_array(visible_groups)
      expect(assigns(:groups)).not_to include(other_group)
    end
  end

  def json_response
    JSON.parse(response.body)
  end
end
