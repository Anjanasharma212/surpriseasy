require 'rails_helper'

RSpec.describe MessagesController, type: :controller do
  login_user

  let(:group) { create(:group, user: controller.current_user) }
  let!(:participant) { create(:participant, group: group, user: controller.current_user) }

  describe 'GET #index' do
    context 'when user is a participant' do
      let!(:normal_message) { create(:message, group: group, sender: controller.current_user, is_anonymous: false) }
      let!(:anonymous_message) { create(:message, :anonymous, group: group, sender: controller.current_user) }

      it 'returns non-anonymous messages' do
        get :index, params: { group_id: group.id }
        
        expect(response).to have_http_status(:ok)
        messages = JSON.parse(response.body)
        expect(messages.length).to eq(1)
        expect(messages.first['id']).to eq(normal_message.id)
      end

      it 'includes sender name for non-anonymous messages' do
        get :index, params: { group_id: group.id }
        
        messages = JSON.parse(response.body)
        expect(messages.first['sender_name']).to eq(controller.current_user.name)
      end
    end

    context 'when user is not a participant' do
      let(:other_group) { create(:group) }

      it 'returns forbidden status' do
        get :index, params: { group_id: other_group.id }
        
        expect(response).to have_http_status(:forbidden)
        expect(JSON.parse(response.body)['error']).to be_present
      end
    end

    context 'when group does not exist' do
      it 'returns not found status' do
        get :index, params: { group_id: 'nonexistent' }
        
        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)['error']).to be_present
      end
    end
  end

  describe 'POST #create' do
    let(:valid_params) do
      {
        group_id: group.id,
        message: {
          content: 'Hello, world!',
          is_anonymous: false
        }
      }
    end

    context 'when user is a participant' do
      it 'creates a new message' do
        expect {
          post :create, params: valid_params
        }.to change(Message, :count).by(1)

        expect(response).to have_http_status(:created)
      end

      it 'creates an anonymous message' do
        params = valid_params.deep_merge(message: { is_anonymous: true })
        
        expect {
          post :create, params: params
        }.to change(Message, :count).by(1)

        expect(response).to have_http_status(:created)
        expect(Message.last.is_anonymous).to be true
      end

      it 'enqueues MessageJob for anonymous messages' do
        params = valid_params.deep_merge(message: { is_anonymous: true })
        
        expect {
          post :create, params: params
        }.to have_enqueued_job(MessageJob)
      end

      context 'when MessageJob fails to enqueue' do
        before do
          allow(MessageJob).to receive(:perform_later).and_raise(StandardError)
        end

        it 'still creates the message but returns a warning' do
          params = valid_params.deep_merge(message: { is_anonymous: true })
          
          post :create, params: params
          
          expect(response).to have_http_status(:created)
          response_body = JSON.parse(response.body)
          expect(response_body['warning']).to be_present
        end
      end
    end

    context 'when user is not a participant' do
      let(:other_group) { create(:group) }

      it 'returns forbidden status' do
        post :create, params: valid_params.merge(group_id: other_group.id)
        
        expect(response).to have_http_status(:forbidden)
        expect(JSON.parse(response.body)['error']).to be_present
      end
    end

    context 'with invalid parameters' do
      let(:invalid_params) do
        {
          group_id: group.id,
          message: {
            content: '',
            is_anonymous: false
          }
        }
      end

      it 'returns unprocessable entity status' do
        post :create, params: invalid_params
        
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['error']).to be_present
      end
    end
  end
end 
