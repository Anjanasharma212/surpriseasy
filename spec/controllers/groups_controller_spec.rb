require 'rails_helper'

RSpec.describe GroupsController, type: :controller do
  # Helper methods directly in the spec
  def setup_devise
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  def create_and_sign_in_user
    setup_devise
    user = create(:user, :invitation_accepted)
    sign_in(user)
    user
  end

  def mock_group_serializer(group)
    allow_any_instance_of(GroupSerializer).to receive(:format_group_details).and_return({
      'id' => group.id,
      'group_name' => group.group_name,
      'event_date' => group.event_date.to_s,
      'budget' => group.budget
    })
  end

  let(:current_user) { create_and_sign_in_user }
  let(:group) { create(:group, user: current_user) }
  let(:valid_attributes) do
    {
      group_name: 'Test Group',
      event_date: Date.tomorrow,
      budget: 1000,
      message: 'Welcome!'
    }
  end

  before do
    # Mock Pundit
    allow(controller).to receive(:policy_scope).with(Group).and_return(Group.all)
    allow(controller).to receive(:authorize).and_return(true)
    
    # Mock GroupSerializer for the current group
    mock_group_serializer(group)
  end

  describe 'GET #group_generator' do
    it 'renders the group_generator template' do
      get :group_generator
      expect(response).to render_template(:group_generator)
    end
  end

  describe 'GET #index' do
    context 'with HTML format' do
      it 'returns a successful response' do
        get :index
        expect(response).to be_successful
      end
    end

    context 'with JSON format' do
      it 'returns groups list when groups exist' do
        group # ensure group exists
        get :index, format: :json
        expect(response).to have_http_status(:success)
      end

      it 'returns not found when no groups exist' do
        Group.destroy_all
        get :index, format: :json
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'GET #show' do
    context 'with HTML format' do
      it 'returns a successful response' do
        get :show, params: { id: group.id }
        expect(response).to be_successful
      end
    end

    context 'with JSON format' do
      it 'returns serialized group details' do
        get :show, params: { id: group.id }, format: :json
        expect(response).to have_http_status(:success)
      end
    end

    context 'when group not found' do
      it 'returns not found status' do
        get :show, params: { id: 'invalid' }, format: :json
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'POST #create' do
    context 'with valid parameters' do
      it 'creates a new group' do
        expect {
          post :create, params: { group: valid_attributes }, format: :json
        }.to change(Group, :count).by(1)
      end

      it 'enqueues GroupEmailJob' do
        expect {
          post :create, params: { group: valid_attributes }, format: :json
        }.to have_enqueued_job(GroupEmailJob)
      end

      it 'returns success message' do
        post :create, params: { group: valid_attributes }, format: :json
        expect(response).to have_http_status(:created)
      end
    end

    context 'with invalid parameters' do
      it 'does not create a new group' do
        expect {
          post :create, params: { group: { group_name: '' } }, format: :json
        }.not_to change(Group, :count)
      end
    end
  end

  describe 'PATCH #update' do
    context 'with HTML format' do
      it 'updates the group and redirects' do
        patch :update, params: { id: group.id, group: valid_attributes }
        expect(response).to redirect_to(groups_path)
      end
    end

    context 'with JSON format' do
      it 'updates the group and returns json' do
        patch :update, params: { id: group.id, group: valid_attributes }, format: :json
        expect(response).to have_http_status(:success)
      end

      it 'returns errors for invalid update' do
        patch :update, params: { id: group.id, group: { group_name: '' } }, format: :json
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the group' do
      group # ensure group exists
      expect {
        delete :destroy, params: { id: group.id }, format: :json
      }.to change(Group, :count).by(-1)
    end

    it 'returns no content status' do
      delete :destroy, params: { id: group.id }, format: :json
      expect(response).to have_http_status(:no_content)
    end

    context 'when destroy fails' do
      before do
        allow_any_instance_of(Group).to receive(:destroy).and_return(false)
      end

      it 'returns unprocessable entity status' do
        delete :destroy, params: { id: group.id }, format: :json
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'Error Handling' do
    context 'when record not found' do
      it 'returns not found status' do
        get :show, params: { id: 'nonexistent' }, format: :json
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'when standard error occurs' do
      before do
        allow(Group).to receive(:find).and_raise(StandardError)
      end

      it 'handles HTML format' do
        get :show, params: { id: 1 }
        expect(response).to redirect_to(groups_path)
        expect(flash[:alert]).to be_present
      end

      it 'handles JSON format' do
        get :show, params: { id: 1 }, format: :json
        expect(response).to have_http_status(:internal_server_error)
      end
    end
  end
end 
